import dot_env
import dot_env/env
import gleam/dict
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/http
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option
import gleam/string_tree
import gleam/uri
import mist
import sqlight
import tempo
import tempo/date
import wisp
import wisp/wisp_mist

pub type GameRecord {
  GameRecord(
    gameid: Int,
    posterid: Int,
    gamename: String,
    winnername: String,
    winnerscore: Int,
    secondname: String,
    secondscore: Int,
    thirdname: option.Option(String),
    thirdscore: option.Option(Int),
    fourthname: option.Option(String),
    fourthscore: option.Option(Int),
    fifthname: option.Option(String),
    fifthscore: option.Option(Int),
    sixthname: option.Option(String),
    sixthscore: option.Option(Int),
    date: String,
  )
}

pub type CustomListRow {
  CustomListRow(id: Int, cardname: String, list: String)
}

pub type CurrentUserGameInformation {
  CurrentUserGameInformation(win_count: Int, total_games: Int)
}

pub type WinPercent {
  WinPercent(name: String, win_count: Int, total_games: Int, win_percent: Float)
}

pub type WinCount {
  WinCount(name: String, win_count: Int)
}

pub type GameStats {
  GameStats(
    gameplaycount: Int,
    playercount: Int,
    userinformation: List(CurrentUserGameInformation),
    winpercent: List(WinPercent),
    wincount: List(WinCount),
  )
}

// decoders
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
  use sixthname <- decode.field("sixthname", decode.optional(decode.string))
  use sixthscore <- decode.field("sixthscore", decode.optional(decode.int))
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
    sixthname,
    sixthscore,
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
  use sixthname <- decode.field("sixthname", decode.optional(decode.string))
  use sixthscore <- decode.field("sixthscore", decode.optional(decode.int))
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
    sixthname,
    sixthscore,
    date,
  ))
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
  use fifthname <- decode.field(11, decode.optional(decode.string))
  use fifthscore <- decode.field(12, decode.optional(decode.int))
  use sixthname <- decode.field(13, decode.optional(decode.string))
  use sixthscore <- decode.field(14, decode.optional(decode.int))
  use date <- decode.field(15, decode.string)

  decode.success(GameRecord(
    gameid,
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
    sixthname,
    sixthscore,
    date,
  ))
}

pub fn location_decoder() {
  use location <- decode.field(0, decode.string)
  decode.success(location)
}

pub fn game_name_decoder() {
  use gamename <- decode.field(0, decode.string)
  decode.success(gamename)
}

pub fn login_decoder() {
  use username <- decode.field("username", decode.string)
  use password <- decode.field("password", decode.string)
  decode.success(#(username, password))
}

pub fn userid_decoder() {
  use id <- decode.field(0, decode.int)
  decode.success(id)
}

pub fn follower_decoder() {
  use follower <- decode.field("follower", decode.int)
  use following <- decode.field("following", decode.string)
  decode.success(#(follower, following))
}

pub fn username_decoder() {
  use name <- decode.field(0, decode.string)
  decode.success(name)
}

pub fn customlist_decoder() {
  use id <- decode.field(0, decode.int)
  use cardname <- decode.field(1, decode.string)
  use list <- decode.field(2, decode.string)

  decode.success(CustomListRow(id, cardname, list))
}

pub fn customlist_tuple_decoder() {
  use id <- decode.field("id", decode.int)
  use cardname <- decode.field("cardname", decode.string)
  use list <- decode.field("list", decode.string)
  decode.success(#(id, cardname, list))
}

pub fn currentuser_stats_decoder() {
  use wins <- decode.field(0, decode.int)
  use plays <- decode.field(1, decode.int)
  decode.success(CurrentUserGameInformation(win_count: wins, total_games: plays))
}

pub fn gameuniqueplayers_decoder() {
  use count <- decode.field(0, decode.int)
  decode.success(count)
}

fn user_stat_decoder() {
  use name <- decode.field(0, decode.string)
  use win_count <- decode.field(1, decode.int)
  use total_games <- decode.field(2, decode.int)
  use win_percent <- decode.field(3, decode.float)
  decode.success(WinPercent(
    name: name,
    win_count: win_count,
    total_games: total_games,
    win_percent: win_percent,
  ))
}

fn win_count_decoder() {
  use name <- decode.field(0, decode.string)
  use win_count <- decode.field(1, decode.int)
  decode.success(WinCount(name: name, win_count: win_count))
}

// endec
pub fn games_row_endec() {
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
  use fifthname <- decode.field(11, decode.optional(decode.string))
  use fifthscore <- decode.field(12, decode.optional(decode.int))
  use sixthname <- decode.field(13, decode.optional(decode.string))
  use sixthscore <- decode.field(14, decode.optional(decode.int))
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
      #(
        "fifthname",
        fifthname |> option.map(json.string) |> option.unwrap(json.null()),
      ),
      #(
        "fifthscore",
        fifthscore |> option.map(json.int) |> option.unwrap(json.null()),
      ),
      #(
        "sixthname",
        sixthname |> option.map(json.string) |> option.unwrap(json.null()),
      ),
      #(
        "sixthscore",
        sixthscore |> option.map(json.int) |> option.unwrap(json.null()),
      ),
      #("date", json.string(date)),
    ])

  decode.success(rowjson)
}

pub fn unique_name_endec() {
  use name <- decode.field(0, decode.optional(decode.string))

  let namejson =
    json.object([
      #("name", name |> option.map(json.string) |> option.unwrap(json.null())),
    ])
  decode.success(namejson)
}

pub fn users_endec() {
  use id <- decode.field(0, decode.int)
  use username <- decode.field(1, decode.string)
  let rowjson =
    json.object([#("id", json.int(id)), #("username", json.string(username))])
  decode.success(rowjson)
}

pub fn follow_endec() {
  use id <- decode.field(0, decode.int)
  let name = get_user_name(id)
  let rowjson = json.object([#("username", json.string(name))])
  decode.success(rowjson)
}

// encoders
pub fn games_row_encoder(record: GameRecord) -> json.Json {
  json.object([
    #("gameid", json.int(record.gameid)),
    #("posterid", json.int(record.posterid)),
    #("gamename", json.string(record.gamename)),
    #("winnername", json.string(record.winnername)),
    #("winnerscore", json.int(record.winnerscore)),
    #("secondname", json.string(record.secondname)),
    #("secondscore", json.int(record.secondscore)),
    #(
      "thirdname",
      record.thirdname |> option.map(json.string) |> option.unwrap(json.null()),
    ),
    #(
      "thirdscore",
      record.thirdscore |> option.map(json.int) |> option.unwrap(json.null()),
    ),
    #(
      "fourthname",
      record.fourthname |> option.map(json.string) |> option.unwrap(json.null()),
    ),
    #(
      "fourthscore",
      record.fourthscore |> option.map(json.int) |> option.unwrap(json.null()),
    ),
    #(
      "fifthname",
      record.fifthname |> option.map(json.string) |> option.unwrap(json.null()),
    ),
    #(
      "fifthscore",
      record.fifthscore |> option.map(json.int) |> option.unwrap(json.null()),
    ),
    #(
      "sixthname",
      record.sixthname |> option.map(json.string) |> option.unwrap(json.null()),
    ),
    #(
      "sixthscore",
      record.sixthscore |> option.map(json.int) |> option.unwrap(json.null()),
    ),
    #("date", json.string(record.date)),
  ])
}

pub fn customlist_encoder(row: CustomListRow) -> json.Json {
  json.object([
    #("id", json.int(row.id)),
    #("cardname", json.string(row.cardname)),
    #("list", json.string(row.list)),
  ])
}

pub fn current_user_encoder(stat: CurrentUserGameInformation) -> json.Json {
  json.object([
    #("wins", json.int(stat.win_count)),
    #("plays", json.int(stat.total_games)),
  ])
}

pub fn user_stat_encoder(stat: WinPercent) -> json.Json {
  json.object([
    #("name", json.string(stat.name)),
    #("win_count", json.int(stat.win_count)),
    #("total_games", json.int(stat.total_games)),
    #("win_percent", json.float(stat.win_percent)),
  ])
}

pub fn win_count_encoder(stat: WinCount) -> json.Json {
  json.object([
    #("name", json.string(stat.name)),
    #("win_count", json.int(stat.win_count)),
  ])
}

pub fn game_stats_encoder(stats: GameStats) -> json.Json {
  json.object([
    #("gameplaycount", json.int(stats.gameplaycount)),
    #("playercount", json.int(stats.playercount)),
    #(
      "userinformation",
      json.array(stats.userinformation, of: current_user_encoder),
    ),
    #("winpercent", json.array(stats.winpercent, of: user_stat_encoder)),
    #("wincounts", json.array(stats.wincount, of: win_count_encoder)),
  ])
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
      ["insertgame"] -> {
        case req.method {
          http.Options -> {
            wisp.ok()
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          http.Post -> {
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
              sixthname,
              sixthscore,
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
              "INSERT INTO gameRecord (gameID, posterID, gameName, winnerName, winnerScore, secondName, secondScore, thirdName, thirdScore, fourthName, fourthScore, fifthName, fifthScore, sixthName, sixthScore, date)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"

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
                  sqlight.nullable(sqlight.text, sixthname),
                  sqlight.nullable(sqlight.int, sixthscore),
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
            |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          _ -> wisp.method_not_allowed([http.Options, http.Post])
        }
      }
      ["updategame"] -> {
        case req.method {
          http.Options -> {
            wisp.ok()
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          http.Post -> {
            use json_result <- wisp.require_json(req)
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
              sixthname,
              sixthscore,
              date,
            )) = decode.run(json_result, update_decoder())

            let assert Ok(conn) = sqlight.open("tracker.db")
            let sql =
              "UPDATE gameRecord SET winnername = ?, winnerscore = ?, secondName = ?, secondScore = ?, thirdName = ?, thirdScore = ?, fourthName = ?, fourthScore = ?, fifthName = ?, fifthScore = ?, sixthname = ?, sixthscore = ?, date = ? WHERE gameID = ?"

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
                  sqlight.nullable(sqlight.text, sixthname),
                  sqlight.nullable(sqlight.int, sixthscore),
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
            |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          _ -> wisp.method_not_allowed([http.Options, http.Post])
        }
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
            expecting: games_row_endec(),
          )
        let gamerows = json.preprocessed_array(rows)
        // wisp.json_response(json.to_string_tree(gamerows), 200)

        json.to_string_tree(gamerows)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      ["usergames", encoded_name, encoded_index] -> {
        let index = case int.parse(encoded_index) {
          Ok(i) -> i
          Error(_) -> 0
        }
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let offset = { index - 1 } * 12
        let limit = 12
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
        // here
        let json = list.map(rows, games_row_encoder)
        let gamejson = json.preprocessed_array(json)

        json.to_string_tree(gamejson)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      ["userfollowinggames", encoded_name, encoded_index] -> {
        let index = case int.parse(encoded_index) {
          Ok(i) -> i
          Error(_) -> 0
        }
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let offset = { index - 1 } * 12
        let limit = 12
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

        let firstdate = case index {
          1 -> {
            tempo.format_utc(tempo.ISO8601Seconds)
          }
          _ ->
            case rows {
              [first, ..] -> {
                io.println(
                  "The date of the first game record is: " <> first.date,
                )
                first.date
              }
              [] -> {
                io.println("No game records found")
                ""
              }
            }
        }
        let lastdate = case list.last(rows) {
          Ok(last) -> {
            last.date
          }
          Error(_) -> {
            io.println("No game records found")
            ""
          }
        }

        let sql = "select id from users where username = ?;"
        let assert Ok([userid]) =
          sqlight.query(
            sql,
            on: conn,
            with: [sqlight.text(name)],
            expecting: userid_decoder(),
          )

        let sql =
          "select distinct users.username from users RIGHT JOIN following ON users.id = following.following where follower = ?;"
        let assert Ok(users) =
          sqlight.query(
            sql,
            on: conn,
            with: [sqlight.int(userid)],
            expecting: username_decoder(),
          )

        let sql =
          "SELECT * FROM gameRecord WHERE (winnerName = ? OR secondName = ?
          OR thirdName = ? OR fourthName = ? OR fifthName = ? OR sixthName = ?)
          AND date <= ? AND date >= ? ORDER BY gameID;"

        let all_rows = following_games(users, firstdate, lastdate, conn, sql)
        let combinedgames = list.append(all_rows, rows)
        let new_rows =
          combinedgames
          |> list.fold(dict.new(), fn(acc, game) {
            dict.insert(acc, game.gameid, game)
          })
          |> dict.values
          |> list.sort(by: fn(a, b) { int.compare(b.gameid, a.gameid) })
        let json = list.map(new_rows, games_row_encoder)
        let gamejson = json.preprocessed_array(json)

        json.to_string_tree(gamejson)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      ["getuserstats", encoded_name] -> {
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let location = case find_location(name) {
          option.Some(location) -> {
            location
          }
          option.None -> {
            io.debug("No location found")
          }
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
            #("location", json.string(location)),
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
      ["getusers"] -> {
        let assert Ok(conn) = sqlight.open("tracker.db")
        let sql = "SELECT id, username FROM users"
        let assert Ok(result) =
          sqlight.query(sql, on: conn, with: [], expecting: users_endec())

        let usernamerows = json.preprocessed_array(result)
        json.to_string_tree(usernamerows)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
      }
      ["login"] -> {
        case req.method {
          http.Options -> {
            wisp.ok()
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header(
              "access-control-allow-methods",
              "GET, POST, OPTIONS",
            )
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          http.Post -> {
            use json_result <- wisp.require_json(req)
            let assert Ok(#(username, password)) =
              decode.run(json_result, login_decoder())

            let assert Ok(conn) = sqlight.open("tracker.db")
            let sql = "SELECT id FROM users WHERE username = ? AND password = ?"

            let assert Ok(result) =
              sqlight.query(
                sql,
                on: conn,
                with: [sqlight.text(username), sqlight.text(password)],
                expecting: userid_decoder(),
              )

            case list.first(result) {
              Ok(userid) -> {
                json.to_string_tree(
                  json.object([#("userid", json.int(userid))]),
                )
                |> wisp.json_response(200)
                |> wisp.set_header("access-control-allow-origin", "*")
                |> wisp.set_header(
                  "access-control-allow-methods",
                  "GET, OPTIONS",
                )
                |> wisp.set_header(
                  "access-control-allow-headers",
                  "Content-Type",
                )
              }
              Error(_) -> {
                json.to_string_tree(json.object([#("userid", json.int(0))]))
                |> wisp.json_response(200)
                |> wisp.set_header("access-control-allow-origin", "*")
                |> wisp.set_header(
                  "access-control-allow-methods",
                  "GET, OPTIONS",
                )
                |> wisp.set_header(
                  "access-control-allow-headers",
                  "Content-Type",
                )
              }
            }
          }
          _ -> {
            wisp.method_not_allowed([http.Options, http.Post])
          }
        }
      }
      ["register"] -> {
        case req.method {
          http.Options -> {
            wisp.ok()
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header(
              "access-control-allow-methods",
              "GET, POST, OPTIONS",
            )
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          http.Post -> {
            use json_result <- wisp.require_json(req)
            let assert Ok(#(username, password)) =
              decode.run(json_result, login_decoder())

            let assert Ok(conn) = sqlight.open("tracker.db")
            let sql =
              "INSERT INTO users (username, password, location) VALUES (?, ?, 'None')"

            let assert Ok(_insert) =
              sqlight.query(
                sql,
                on: conn,
                with: [sqlight.text(username), sqlight.text(password)],
                expecting: userid_decoder(),
              )

            let sql = "SELECT id FROM users WHERE username = ? AND password = ?"
            let assert Ok(result) =
              sqlight.query(
                sql,
                on: conn,
                with: [sqlight.text(username), sqlight.text(password)],
                expecting: userid_decoder(),
              )

            case list.first(result) {
              Ok(userid) -> {
                json.to_string_tree(
                  json.object([#("userid", json.int(userid))]),
                )
                |> wisp.json_response(200)
                |> wisp.set_header("access-control-allow-origin", "*")
                |> wisp.set_header(
                  "access-control-allow-methods",
                  "GET, OPTIONS",
                )
                |> wisp.set_header(
                  "access-control-allow-headers",
                  "Content-Type",
                )
              }
              Error(_) -> {
                json.to_string_tree(json.object([#("userid", json.int(0))]))
                |> wisp.json_response(200)
                |> wisp.set_header("access-control-allow-origin", "*")
                |> wisp.set_header(
                  "access-control-allow-methods",
                  "GET, OPTIONS",
                )
                |> wisp.set_header(
                  "access-control-allow-headers",
                  "Content-Type",
                )
              }
            }
          }
          _ -> {
            wisp.method_not_allowed([http.Options, http.Post])
          }
        }
      }
      ["getuserelationship"] -> {
        case req.method {
          http.Options -> {
            wisp.ok()
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header(
              "access-control-allow-methods",
              "GET, POST, OPTIONS",
            )
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          http.Post -> {
            use json_result <- wisp.require_json(req)
            let assert Ok(#(follower, following)) =
              decode.run(json_result, follower_decoder())

            let userid = get_user_id(following)
            let assert Ok(conn) = sqlight.open("tracker.db")
            let sql =
              "SELECT EXISTS (SELECT 1 FROM following WHERE follower = ? AND following = ?)"
            let assert Ok(relationshipexistencelist) =
              sqlight.query(
                sql,
                on: conn,
                with: [sqlight.int(follower), sqlight.int(userid)],
                expecting: userid_decoder(),
              )

            let relationshipexistence = case
              list.first(relationshipexistencelist)
            {
              Ok(relationshipexistence) -> relationshipexistence
              Error(_) -> 0
            }

            case relationshipexistence {
              0 -> {
                let followed_user_json =
                  json.object([
                    #("relationship", json.string("Not Following User")),
                  ])

                json.to_string_tree(followed_user_json)
                |> wisp.json_response(200)
                |> wisp.set_header("access-control-allow-origin", "*")
                |> wisp.set_header(
                  "access-control-allow-methods",
                  "POST, OPTIONS",
                )
                |> wisp.set_header(
                  "access-control-allow-headers",
                  "Content-Type",
                )
              }
              _ -> {
                let followed_user_json =
                  json.object([#("relationship", json.string("Following User"))])

                json.to_string_tree(followed_user_json)
                |> wisp.json_response(200)
                |> wisp.set_header("access-control-allow-origin", "*")
                |> wisp.set_header(
                  "access-control-allow-methods",
                  "POST, OPTIONS",
                )
                |> wisp.set_header(
                  "access-control-allow-headers",
                  "Content-Type",
                )
              }
            }
          }
          _ -> {
            wisp.method_not_allowed([http.Options, http.Post])
          }
        }
      }
      ["getfollowers", encoded_name] -> {
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let userid = get_user_id(name)
        let assert Ok(conn) = sqlight.open("tracker.db")
        let sql = "SELECT follower FROM following where following = ?"
        let assert Ok(result) =
          sqlight.query(
            sql,
            on: conn,
            with: [sqlight.int(userid)],
            expecting: follow_endec(),
          )

        let followers = json.preprocessed_array(result)
        json.to_string_tree(followers)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
        |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
        |> wisp.set_header("access-control-allow-headers", "Content-Type")
      }
      ["getfollowing", encoded_name] -> {
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let userid = get_user_id(name)
        let assert Ok(conn) = sqlight.open("tracker.db")
        let sql = "SELECT following FROM following where follower = ?"
        let assert Ok(result) =
          sqlight.query(
            sql,
            on: conn,
            with: [sqlight.int(userid)],
            expecting: follow_endec(),
          )

        let following = json.preprocessed_array(result)
        json.to_string_tree(following)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
        |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
        |> wisp.set_header("access-control-allow-headers", "Content-Type")
      }
      ["followuser"] -> {
        case req.method {
          http.Options -> {
            wisp.ok()
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header(
              "access-control-allow-methods",
              "GET, POST, OPTIONS",
            )
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          http.Post -> {
            use json_result <- wisp.require_json(req)
            let assert Ok(#(follower, following)) =
              decode.run(json_result, follower_decoder())

            let userid = get_user_id(following)
            let assert Ok(conn) = sqlight.open("tracker.db")
            let sql =
              "SELECT EXISTS (SELECT 1 FROM following WHERE follower = ? AND following = ?)"
            let assert Ok(relationshipexistencelist) =
              sqlight.query(
                sql,
                on: conn,
                with: [sqlight.int(follower), sqlight.int(userid)],
                expecting: userid_decoder(),
              )

            let relationshipexistence = case
              list.first(relationshipexistencelist)
            {
              Ok(relationshipexistence) -> relationshipexistence
              Error(_) -> 0
            }

            case relationshipexistence {
              0 -> {
                let sql =
                  "INSERT INTO following (follower, following) VALUES (?, ?)"
                let assert Ok(_result) =
                  sqlight.query(
                    sql,
                    on: conn,
                    with: [sqlight.int(follower), sqlight.int(userid)],
                    expecting: userid_decoder(),
                  )

                let followed_user_json =
                  json.object([#("event", json.string("Followed User"))])

                json.to_string_tree(followed_user_json)
                |> wisp.json_response(200)
                |> wisp.set_header("access-control-allow-origin", "*")
                |> wisp.set_header(
                  "access-control-allow-methods",
                  "POST, OPTIONS",
                )
                |> wisp.set_header(
                  "access-control-allow-headers",
                  "Content-Type",
                )
              }
              _ -> {
                let followed_user_json =
                  json.object([#("event", json.string("User Already Followed"))])

                json.to_string_tree(followed_user_json)
                |> wisp.json_response(200)
                |> wisp.set_header("access-control-allow-origin", "*")
                |> wisp.set_header(
                  "access-control-allow-methods",
                  "POST, OPTIONS",
                )
                |> wisp.set_header(
                  "access-control-allow-headers",
                  "Content-Type",
                )
              }
            }
          }
          _ -> {
            wisp.method_not_allowed([http.Options, http.Post])
          }
        }
      }
      ["unfollowuser"] -> {
        case req.method {
          http.Options -> {
            wisp.ok()
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header(
              "access-control-allow-methods",
              "GET, POST, OPTIONS",
            )
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          http.Post -> {
            use json_result <- wisp.require_json(req)
            let assert Ok(#(follower, following)) =
              decode.run(json_result, follower_decoder())

            let userid = get_user_id(following)
            let assert Ok(conn) = sqlight.open("tracker.db")
            let sql =
              "DELETE FROM following WHERE follower = ? AND following = ?"
            let assert Ok(_result) =
              sqlight.query(
                sql,
                on: conn,
                with: [sqlight.int(follower), sqlight.int(userid)],
                expecting: userid_decoder(),
              )

            let followed_user_json =
              json.object([#("event", json.string("Unfollowed User"))])

            json.to_string_tree(followed_user_json)
            |> wisp.json_response(200)
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          _ -> {
            wisp.method_not_allowed([http.Options, http.Post])
          }
        }
      }
      ["getusercustomlists", encoded_name] -> {
        let name = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let userid = get_user_id(name)
        let assert Ok(conn) = sqlight.open("tracker.db")
        let sql =
          "SELECT id, cardName, listName FROM dominionCustomLists WHERE id = ?"
        let assert Ok(result) =
          sqlight.query(
            sql,
            on: conn,
            with: [sqlight.int(userid)],
            expecting: customlist_decoder(),
          )

        let json_list = list.map(result, customlist_encoder)
        let json_array = json.preprocessed_array(json_list)

        json.to_string_tree(json_array)
        |> wisp.json_response(200)
        |> wisp.set_header("access-control-allow-origin", "*")
        |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
        |> wisp.set_header("access-control-allow-headers", "Content-Type")
      }
      ["addtocustomlist"] -> {
        case req.method {
          http.Options -> {
            wisp.ok()
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header(
              "access-control-allow-methods",
              "GET, POST, OPTIONS",
            )
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          http.Post -> {
            use json_result <- wisp.require_json(req)
            let assert Ok(#(id, cardname, list)) =
              decode.run(json_result, customlist_tuple_decoder())

            let assert Ok(conn) = sqlight.open("tracker.db")
            let sql = "INSERT INTO dominionCustomLists VALUES (?, ?, ?);"
            let assert Ok(_result) =
              sqlight.query(
                sql,
                on: conn,
                with: [
                  sqlight.int(id),
                  sqlight.text(cardname),
                  sqlight.text(list),
                ],
                expecting: customlist_decoder(),
              )

            let followed_user_json =
              json.object([#("event", json.string("Added Card to Custom List"))])

            json.to_string_tree(followed_user_json)
            |> wisp.json_response(200)
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          _ -> {
            wisp.method_not_allowed([http.Options, http.Post])
          }
        }
      }
      ["removefromcustomlist"] -> {
        case req.method {
          http.Options -> {
            wisp.ok()
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header(
              "access-control-allow-methods",
              "GET, POST, OPTIONS",
            )
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          http.Post -> {
            use json_result <- wisp.require_json(req)
            let assert Ok(#(id, cardname, list)) =
              decode.run(json_result, customlist_tuple_decoder())

            let assert Ok(conn) = sqlight.open("tracker.db")
            let sql =
              "DELETE FROM dominionCustomLists WHERE id = ? AND cardName = ? AND listName = ?;"
            let assert Ok(_result) =
              sqlight.query(
                sql,
                on: conn,
                with: [
                  sqlight.int(id),
                  sqlight.text(cardname),
                  sqlight.text(list),
                ],
                expecting: customlist_decoder(),
              )

            let followed_user_json =
              json.object([
                #("event", json.string("Removed Card from Custom List")),
              ])

            json.to_string_tree(followed_user_json)
            |> wisp.json_response(200)
            |> wisp.set_header("access-control-allow-origin", "*")
            |> wisp.set_header("access-control-allow-methods", "POST, OPTIONS")
            |> wisp.set_header("access-control-allow-headers", "Content-Type")
          }
          _ -> {
            wisp.method_not_allowed([http.Options, http.Post])
          }
        }
      }
      ["getgameinformation", encoded_user, encoded_name] -> {
        let user = case uri.percent_decode(encoded_user) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let gamename = case uri.percent_decode(encoded_name) {
          Ok(decoded_name) -> decoded_name
          Error(_) -> "Invalid name"
        }

        let currentuserinformation =
          get_currentuser_game_information(user, gamename)
        let playcount = get_game_play_count(gamename)
        let playercount = get_unique_name_count(gamename)
        let winpercent = get_highest_win_percentage(gamename)
        let wincount = get_win_count(gamename)
        let result =
          GameStats(
            gameplaycount: playcount,
            playercount: playercount,
            userinformation: currentuserinformation,
            winpercent: winpercent,
            wincount: wincount,
          )

        game_stats_encoder(result)
        |> json.to_string_tree
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
    |> mist.port(6220)
    |> mist.bind("0.0.0.0")
    |> mist.start_http
  process.sleep_forever()
}

pub fn find_location(name) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql = "SELECT location FROM users WHERE username = ?;"
  let assert Ok(locations) =
    sqlight.query(
      sql,
      on: conn,
      with: [sqlight.text(name)],
      expecting: location_decoder(),
    )

  case locations {
    [location, ..] -> option.Some(location)
    [] -> option.None
  }
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
      expecting: games_row_endec(),
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
      expecting: games_row_endec(),
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
    "SELECT name, COUNT(*) as frequency
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
    WHERE name != ? AND name IS NOT NULL
    GROUP BY name
    ORDER BY frequency DESC;"

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
      expecting: unique_name_endec(),
    )
  unique_names
}

pub fn get_user_id(username: String) {
  let name = case uri.percent_decode(username) {
    Ok(decoded_name) -> decoded_name
    Error(_) -> "Invalid name"
  }

  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql = "SELECT id FROM users WHERE username = ? LIMIT 1"
  let assert Ok(userid_list) =
    sqlight.query(
      sql,
      on: conn,
      with: [sqlight.text(name)],
      expecting: userid_decoder(),
    )

  case list.first(userid_list) {
    Ok(id) -> id
    Error(_) -> 0
  }
}

pub fn get_user_name(userid: Int) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql = "SELECT username FROM users WHERE id = ? LIMIT 1"
  let assert Ok(username_list) =
    sqlight.query(
      sql,
      on: conn,
      with: [sqlight.int(userid)],
      expecting: username_decoder(),
    )

  case list.first(username_list) {
    Ok(username) -> username
    Error(_) -> ""
  }
}

pub fn following_games(
  users: List(String),
  startdate,
  enddate,
  conn,
  sql,
) -> List(GameRecord) {
  following_games_recursive(users, startdate, enddate, conn, sql, [])
}

fn following_games_recursive(
  users: List(String),
  startdate,
  enddate,
  conn,
  sql,
  acc: List(GameRecord),
) -> List(GameRecord) {
  case users {
    [] -> acc
    // Base case: return the accumulated rows
    [head, ..tail] -> {
      let assert Ok(rows) =
        sqlight.query(
          sql,
          on: conn,
          with: [
            sqlight.text(head),
            sqlight.text(head),
            sqlight.text(head),
            sqlight.text(head),
            sqlight.text(head),
            sqlight.text(head),
            sqlight.text(startdate),
            sqlight.text(enddate),
          ],
          expecting: games_row_decoder(),
        )

      // Add the rows to the accumulator and recurse
      let new_acc = list.append(acc, rows)
      following_games_recursive(tail, startdate, enddate, conn, sql, new_acc)
    }
  }
}

pub fn get_currentuser_game_information(username: String, gamename: String) {
  io.debug(username)
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql =
    "SELECT
      SUM(CASE WHEN winnerName = ? THEN 1 ELSE 0 END) AS wins,
      SUM(CASE WHEN winnerName = ? THEN 1 ELSE 0 END) +
      SUM(CASE WHEN secondName = ? THEN 1 ELSE 0 END) +
      SUM(CASE WHEN thirdName = ? THEN 1 ELSE 0 END) +
      SUM(CASE WHEN fourthName = ? THEN 1 ELSE 0 END) +
      SUM(CASE WHEN fifthName = ? THEN 1 ELSE 0 END) +
      SUM(CASE WHEN sixthName = ? THEN 1 ELSE 0 END) AS total_appearances
    FROM gameRecord WHERE gamename = ?;"

  let assert Ok(row) =
    sqlight.query(
      sql,
      on: conn,
      with: [
        sqlight.text(username),
        sqlight.text(username),
        sqlight.text(username),
        sqlight.text(username),
        sqlight.text(username),
        sqlight.text(username),
        sqlight.text(username),
        sqlight.text(gamename),
      ],
      expecting: currentuser_stats_decoder(),
    )
  row
}

pub fn get_game_play_count(gamename: String) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql = "SELECT COUNT(*) AS playCount FROM gameRecord WHERE gamename = ?;"

  let assert Ok([row]) =
    sqlight.query(
      sql,
      on: conn,
      with: [sqlight.text(gamename)],
      expecting: gameuniqueplayers_decoder(),
    )
  row
}

pub fn get_unique_name_count(gamename: String) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql =
    "SELECT COUNT(*) AS uniquePlayerCount FROM (
        SELECT winnerName AS name FROM gameRecord WHERE gamename = ? AND winnerName IS NOT NULL
      UNION
        SELECT secondName FROM gameRecord WHERE gamename = ? AND secondName IS NOT NULL
      UNION
        SELECT thirdName FROM gameRecord WHERE gamename = ? AND thirdName IS NOT NULL
      UNION
        SELECT fourthName FROM gameRecord WHERE gamename = ? AND fourthName IS NOT NULL
      UNION
        SELECT fifthName FROM gameRecord WHERE gamename = ? AND fifthName IS NOT NULL
      UNION
        SELECT sixthName FROM gameRecord WHERE gamename = ? AND sixthName IS NOT NULL);"

  let assert Ok([row]) =
    sqlight.query(
      sql,
      on: conn,
      with: [
        sqlight.text(gamename),
        sqlight.text(gamename),
        sqlight.text(gamename),
        sqlight.text(gamename),
        sqlight.text(gamename),
        sqlight.text(gamename),
      ],
      expecting: gameuniqueplayers_decoder(),
    )
  row
}

pub fn get_highest_win_percentage(gamename: String) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql =
    "WITH Wins AS (
      SELECT winnerName AS name, COUNT(*) AS winCount
      FROM gameRecord WHERE gamename = ? GROUP BY winnerName
    ),
    OtherPositions AS (
      SELECT name, SUM(appearance_count) AS otherCount
      FROM (
        SELECT winnerName AS name, COUNT(*) AS appearance_count FROM gameRecord WHERE gamename = ? GROUP BY winnerName
          UNION ALL
        SELECT secondName AS name, COUNT(*) AS appearance_count FROM gameRecord WHERE gamename = ? GROUP BY secondName
          UNION ALL
        SELECT thirdName, COUNT (*) FROM gameRecord WHERE gamename = ? GROUP BY thirdName
          UNION ALL
        SELECT fourthName, COUNT(*) FROM gameRecord WHERE gamename = ? GROUP BY fourthName
          UNION ALL
        SELECT fifthName, COUNT(*) FROM gameRecord WHERE gamename = ? GROUP BY fifthName
          UNION ALL
        SELECT sixthName, COUNT(*) FROM gameRecord WHERE gamename = ? GROUP BY sixthName
      ) AS Combined
      GROUP BY name
    ),
    Results AS (
      SELECT 
        w.name, w.winCount, COALESCE(o.otherCount, 0) AS totalGames,
        (CAST(w.winCount AS FLOAT) / NULLIF(COALESCE(o.otherCount, 0), 0)) * 100 AS winPercent
      FROM Wins w
      LEFT JOIN OtherPositions o ON w.name = o.name
      WHERE totalGames > 2
    )
    SELECT * FROM Results WHERE winPercent = (SELECT MAX(winPercent) FROM Results);"

  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: conn,
      with: [
        sqlight.text(gamename),
        sqlight.text(gamename),
        sqlight.text(gamename),
        sqlight.text(gamename),
        sqlight.text(gamename),
        sqlight.text(gamename),
        sqlight.text(gamename),
      ],
      expecting: user_stat_decoder(),
    )
  rows
}

pub fn get_win_count(gamename: String) {
  let assert Ok(conn) = sqlight.open("tracker.db")
  let sql =
    "SELECT winnerName, COUNT(*) AS winCount FROM gameRecord WHERE gamename = ? GROUP BY winnerName ORDER BY winCount DESC;"

  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: conn,
      with: [sqlight.text(gamename)],
      expecting: win_count_decoder(),
    )
  rows
}
