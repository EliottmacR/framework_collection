-- game = {
  -- path = ""
-- }

-- games = {
  -- id : game
-- }

games = {
  {name = "fishing_game", path = "https://raw.githubusercontent.com/EliottmacR/FishingGame/master/game_template.lua"}
}



-- function get_path_from_id(game_id)
  -- if not game_id then return end
  -- return games[game_id].path  
-- end
  
function get_id_from_name(game_name)
  if not game_name then return end
  for ind, game in pairs(games) do
    if game.name == game_name then return ind end  
  end  
end
  
  
  