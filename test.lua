-- === 4. Detect private server status and print info ===
print("PrivateServerId:", tostring(game.PrivateServerId))
print("PrivateServerOwnerId:", tostring(game.PrivateServerOwnerId))
print("JobId:", tostring(game.JobId))

if game.PrivateServerId ~= "" then
    local placeId = game.PlaceId
    local code = game.PrivateServerId
    print("You are in an official private server!")
    local joinLink = ("https://www.roblox.com/games/%d?privateServerLinkCode=%s"):format(placeId, code)
    print("Join link: " .. joinLink)
elseif game.JobId ~= "" and game.PrivateServerOwnerId == "" then
    print("You might be in a reserved/matchmaking server (not an official private server)!")
else
    print("You are in a public server.")
end
