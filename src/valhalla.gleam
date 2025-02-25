import dot_env
import dot_env/env
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option
import gleam/string_tree
import gleam/uri
import mist
import sqlight
import tempo/date
import wisp
import wisp/wisp_mist

pub fn game_name_decoder() {
  use gamename <- decode.field(0, decode.string)

  // let rowjson = json.object([#("gamename", json.string(gamename))])
  decode.success(gamename)
}

pub fn unique_name_decoder() {
  use name <- decode.field(0, decode.optional(decode.string))

  let namejson =
    json.object([
      #("name", name |> option.map(json.string) |> option.unwrap(json.null())),
    ])
  decode.success(namejson)
}

pub fn games_row_decoder() {
  use gameid <- decode.field(0, decode.int)
  use posterid <- decode.field(1, decode.int)
  use gamename <- decode.field(2, decode.string)
  use winnername <- decode.field(3, decode.string)
  use winnerscore <- decode.field(4, decode.int)
  use secondname <- decode.field(5, decode.string)
  use secondscore <- decode.field(6, decode.int)
  use thirdname <- decode.field(7, decode.optional(decode.string))
  use thirdscore <- decode.field(8, decode.optional(decode.int))
  use fourthname <- decode.field(9, decode.optional(decode.string))
  use fourthscore <- decode.field(10, decode.optional(decode.int))
  use date <- decode.field(15, decode.string)

  let rowjson =
    json.object([
      #("gameid", json.int(gameid)),
      #("posterid", json.int(posterid)),
      #("gamename", json.string(gamename)),
      #("winnername", json.string(winnername)),
      #("winnerscore", json.int(winnerscore)),
      #("secondname", json.string(secondname)),
      #("secondscore", json.int(secondscore)),
      #(
        "thirdname",
        thirdname |> option.map(json.string) |> option.unwrap(json.null()),
      ),
      #(
        "thirdscore",
        thirdscore |> option.map(json.int) |> option.unwrap(json.null()),
      ),
      #(
        "fourthname",
        fourthname |> option.map(json.string) |> option.unwrap(json.null()),
      ),
      #(
        "fourthscore",
        fourthscore |> option.map(json.int) |> option.unwrap(json.null()),
      ),
      #("date", json.string(date)),
    ])

  // Return the JSON object as the decoded result
  decode.success(rowjson)
}

fn insert_decoder() {
  use posterid <- decode.field("posterid", decode.int)
  use gamename <- decode.field("gamename", decode.string)
  use winnername <- decode.field("winnername", decode.string)
  use winnerscore <- decode.field("winnerscore", decode.int)
  use secondname <- decode.field("secondname", decode.string)
  use secondscore <- decode.field("secondscore", decode.int)
  use thirdname <- decode.field("thirdname", decode.optional(decode.string))
  use thirdscore <- decode.field("thirdscore", decode.optional(decode.int))
  use fourthname <- decode.field("fourthname", decode.optional(decode.string))
  use fourthscore <- decode.field("fourthscore", decode.optional(decode.int))
  use fifthname <- decode.field("fifthname", decode.optional(decode.string))
  use fifthscore <- decode.field("fifthscore", decode.optional(decode.int))
  use date <- decode.field("date", decode.optional(decode.string))

  decode.success(#(
    posterid,
    gamename,
    winnername,
    winnerscore,
    secondname,
    secondscore,
    thirdname,
    thirdscore,
    fourthname,
    fourthscore,
    fifthname,
    fifthscore,
    date,
  ))
}

fn update_decoder() {
  use gameid <- decode.field("gameid", decode.int)
  use winnername <- decode.field("winnername", decode.string)
  use winnerscore <- decode.field("winnerscore", decode.int)
  use secondname <- decode.field("secondname", decode.string)
  use secondscore <- decode.field("secondscore", decode.int)
  use thirdname <- decode.field("thirdname", decode.optional(decode.string))
  use thirdscore <- decode.field("thirdscore", decode.optional(decode.int))
  use fourthname <- decode.field("fourthname", decode.optional(decode.string))
  use fourthscore <- decode.field("fourthscore", decode.optional(decode.int))
  use fifthname <- decode.field("fifthname", decode.optional(decode.string))
  use fifthscore <- decode.field("fifthscore", decode.optional(decode.int))
  use date <- decode.field("date", decode.string)

  decode.success(#(
    gameid,
    winnername,
    winnerscore,
    secondname,
    secondscore,
    thirdname,
    thirdscore,
    fourthname,
    fourthscore,
    fifthname,
    fifthscore,
    date,
  ))
}

pub fn main() {
  wisp.configure_logger()

  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load
  let assert Ok(secret_key_base) = env.get_string("SECRET_KEY_BASE")

  // Define the request handler
  let handler = fn(req) {
    case wisp.path_segments(req) {
      [] -> {
        wisp.html_response(string_tree.from_string("Hello"), 200)
      }
      ["showgames", encoded_name] -> {
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }
        io.debug("Retrieving Games For " <> name)

        let assert Ok(conn) = sqlight.open("tracker.db")
        let sql =
          "SELECT * FROM gameRecord WHERE winnerName = ? OR secondName = ?
          OR thirdName = ? OR fourthName = ? OR fifthName = ? OR sixthName = ? ORDER BY gameID DESC;"

        let assert Ok(rows) =
          sqlight.query(
            sql,
            on: conn,
            with: [ 
              sqlight.text(name),
              sqlight.text(name),
              sqlight.text(name),
              sqlight.text(name),
              sqlight.text(name),
              sqlight.text(name),
            ],
            expecting: games_row_decoder(),
          )
        let gamerows = json.preprocessed_array(rows)
        // wisp.json_response(json.to_string_tree(gamerows), 200)

        json.to_string_tree(gamerows)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      ["homepagegames", encoded_name, encoded_index] -> {
        let index = case int.parse(encoded_index) {
          Ok(i) -> i
          Error(_) -> 0
        }
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }
        io.debug("Retrieving Games For " <> name)
        io.debug("Index " <> int.to_string(index))
        let offset = {index - 1} * 12
        let limit = 12
        io.debug(offset)
        io.debug(limit)

        let assert Ok(conn) = sqlight.open("tracker.db")
        let sql =
          "SELECT * FROM gameRecord WHERE winnerName = ? OR secondName = ?
          OR thirdName = ? OR fourthName = ? OR fifthName = ? OR sixthName = ? ORDER BY gameID DESC LIMIT ? OFFSET ?;"

        let assert Ok(rows) =
          sqlight.query(
            sql,
            on: conn,
            with: [
              sqlight.text(name),
              sqlight.text(name),
              sqlight.text(name),
              sqlight.text(name),
              sqlight.text(name),
              sqlight.text(name),
              sqlight.int(limit),
              sqlight.int(offset),
            ],
            expecting: games_row_decoder(),
          )
        let gamerows = json.preprocessed_array(rows)
        // wisp.json_response(json.to_string_tree(gamerows), 200)

        json.to_string_tree(gamerows)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      ["insertgame"] -> {
        io.debug("Inserting Game")
        use json_result <- wisp.require_json(req)
        let assert Ok(#(
          posterid,
          gamename,
          winnername,
          winnerscore,
          secondname,
          secondscore,
          thirdname,
          thirdscore,
          fourthname,
          fourthscore,
          fifthname,
          fifthscore,
          date,
        )) = decode.run(json_result, insert_decoder())

        let assert Ok(conn) = sqlight.open("tracker.db")

        let sql_gameid = "SELECT MAX(gameID) FROM gameRecord;"
        let assert Ok([[maxgameid]]) =
          sqlight.query(
            sql_gameid,
            with: [],
            on: conn,
            expecting: decode.list(decode.int),
          )

        let gamedate = case date {
          option.Some(date) -> date
          option.None -> {
            date.current_local()
            |> date.to_string
          }
        }

        let sql =
          "INSERT INTO gameRecord (gameID, posterID, gameName, winnerName, winnerScore, secondName, secondScore, thirdName, thirdScore, fourthName, fourthScore, fifthName, fifthScore, date)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"

        let _ =
          io.debug(
            sqlight.query(sql, conn, decode.int, with: [
              sqlight.int(maxgameid + 1),
              sqlight.int(posterid),
              sqlight.text(gamename),
              sqlight.text(winnername),
              sqlight.int(winnerscore),
              sqlight.text(secondname),
              sqlight.int(secondscore),
              sqlight.nullable(sqlight.text, thirdname),
              sqlight.nullable(sqlight.int, thirdscore),
              sqlight.nullable(sqlight.text, fourthname),
              sqlight.nullable(sqlight.int, fourthscore),
              sqlight.nullable(sqlight.text, fifthname),
              sqlight.nullable(sqlight.int, fifthscore),
              sqlight.text(gamedate),
            ]),
          )

        let inserted_game_json =
          json.object([
            #("gameid", json.int(maxgameid + 1)),
            #("event", json.string("Inserted")),
          ])

        json.to_string_tree(inserted_game_json)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      ["updategame"] -> {
        use json_result <- wisp.require_json(req)
        io.debug("updating Game")
        io.debug(json_result)
        let assert Ok(#(
          gameid,
          winnername,
          winnerscore,
          secondname,
          secondscore,
          thirdname,
          thirdscore,
          fourthname,
          fourthscore,
          fifthname,
          fifthscore,
          date,
        )) = decode.run(json_result, update_decoder())

        let assert Ok(conn) = sqlight.open("tracker.db")
        let sql =
          "UPDATE gameRecord SET winnername = ?, winnerscore = ?, secondName = ?, secondScore = ?, thirdName = ?, thirdScore = ?, fourthName = ?, fourthScore = ?, fifthName = ?, fifthScore = ?, date = ? WHERE gameID = ?"

        let _ =
          io.debug(
            sqlight.query(sql, conn, decode.int, with: [
              sqlight.text(winnername),
              sqlight.int(winnerscore),
              sqlight.text(secondname),
              sqlight.int(secondscore),
              sqlight.nullable(sqlight.text, thirdname),
              sqlight.nullable(sqlight.int, thirdscore),
              sqlight.nullable(sqlight.text, fourthname),
              sqlight.nullable(sqlight.int, fourthscore),
              sqlight.nullable(sqlight.text, fifthname),
              sqlight.nullable(sqlight.int, fifthscore),
              sqlight.text(date),
              sqlight.int(gameid),
            ]),
          )

        let updated_game_json =
          json.object([
            #("gameid", json.int(gameid)),
            #("event", json.string("Updated")),
          ])
        json.to_string_tree(updated_game_json)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      ["getuserstats", encoded_name] -> {
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let gamesplayed = calc_games_played(name)
        let gameswon = calc_games_won(name)
        let mostplayed = calc_most_played(name)
        let mostwon = calc_most_won(name)
        let player_stats_json =
          json.object([
            #("user", json.string(name)),
            #("gamesplayed", json.int(gamesplayed)),
            #("gameswon", json.int(gameswon)),
            #("mostplayed", json.string(mostplayed)),
            #("mostwon", json.string(mostwon)),
          ])

        json.to_string_tree(player_stats_json)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      ["getuseruniqueplayers", encoded_name] -> {
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let unique_names = find_unique_names(name)
        let name_rows = json.preprocessed_array(unique_names)

        json.to_string_tree(name_rows)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      _ -> wisp.not_found()
    }
  }

  // Start the HTTP server
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http
  process.sleep_forever()
}

pub fn calc_games_played(name) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql =
    "SELECT * FROM gameRecord WHERE winnerName = ? OR secondName = ?
    OR thirdName = ? OR fourthName = ? OR fifthName = ? OR sixthName = ?;"
  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: conn,
      with: [
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
      ],
      expecting: games_row_decoder(),
    )

  let gamesplayed = list.length(rows)
  gamesplayed
}

pub fn calc_games_won(name) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql = "SELECT * FROM gameRecord WHERE winnerName = ?;"
  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: conn,
      with: [sqlight.text(name)],
      expecting: games_row_decoder(),
    )

  let gameswon = list.length(rows)
  gameswon
}

pub fn calc_most_played(name) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql =
    "SELECT gameName FROM gameRecord WHERE winnerName = ? OR secondName = ?
    OR thirdName = ? OR fourthName = ? OR fifthName = ? OR sixthName = ?;"
  let assert Ok(all_games) =
    sqlight.query(
      sql,
      on: conn,
      with: [
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
      ],
      expecting: game_name_decoder(),
    )

  let games = list.unique(all_games)
  let game_counts =
    list.map(games, fn(game) {
      let game_count = list.count(all_games, fn(all_game) { all_game == game })
      #(game, game_count)
    })

  let most_playedgame =
    list.fold(game_counts, #("", 0), fn(acc, game_count) {
      let #(_, acc_count) = acc
      let #(_, count) = game_count
      case count > acc_count {
        True -> game_count
        False -> acc
      }
    })
    |> fn(result) { result.0 }
  most_playedgame
}

pub fn calc_most_won(name) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql = "SELECT gameName FROM gameRecord WHERE winnerName = ?;"
  let assert Ok(all_wins) =
    sqlight.query(
      sql,
      on: conn,
      with: [sqlight.text(name)],
      expecting: game_name_decoder(),
    )

  let games = list.unique(all_wins)
  let win_counts =
    list.map(games, fn(game) {
      let win_count = list.count(all_wins, fn(all_game) { all_game == game })
      #(game, win_count)
    })

  let most_wongame =
    list.fold(win_counts, #("", 0), fn(acc, win_count) {
      let #(_, acc_count) = acc
      let #(_, count) = win_count
      case count > acc_count {
        True -> win_count
        False -> acc
      }
    })
    |> fn(result) { result.0 }
  most_wongame
}

pub fn find_unique_names(name) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql =
    "SELECT DISTINCT name
    FROM (
      SELECT winnerName AS name FROM gameRecord WHERE winnerName = ? OR secondName = ? OR thirdName = ? OR fourthName = ? OR fifthName = ?
      UNION ALL
      SELECT secondName FROM gameRecord WHERE winnerName = ? OR secondName = ? OR thirdName = ? OR fourthName = ? OR fifthName = ?
      UNION ALL
      SELECT thirdName FROM gameRecord WHERE winnerName = ? OR secondName = ? OR thirdName = ? OR fourthName = ? OR fifthName = ?
      UNION ALL
      SELECT fourthName FROM gameRecord WHERE winnerName = ? OR secondName = ? OR thirdName = ? OR fourthName = ? OR fifthName = ?
      UNION ALL
      SELECT fifthName FROM gameRecord WHERE winnerName = ? OR secondName = ? OR thirdName = ? OR fourthName = ? OR fifthName = ?
    ) AS names
    WHERE name != ? AND name IS NOT NULL;"
  let assert Ok(unique_names) =
    sqlight.query(
      sql,
      on: conn,
      with: [
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
        sqlight.text(name),
      ],
      expecting: unique_name_decoder(),
    )
  unique_names
}
// let name = "Pac-Man"
// let my_json =
//   json.to_string(
//     json.object([
//       #("game", json.string(name)),
//       #("score", json.int(3_333_360)),
//     ]),
//   )
// let assert Ok(_) =
//   wisp_mist.handler(
//     fn(_) {
//       wisp.json_response(
//         string_tree.from_string(my_json),
//         200,
//       )
//     },
//     secret_key_base,
//   )
//   // wisp_mist.handler(fn(_) { wisp.html_response(string_tree.from_string("Hello"), 200) }, "secret_key")
//   |> mist.new
//   |> mist.port(8000)
//   |> mist.start_http

// process.sleep_forever()
