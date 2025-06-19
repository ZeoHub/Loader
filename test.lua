

-- === 3. Detect if you are in a private server ===
if game.PrivateServerId ~= "" then
    local placeId = game.PlaceId
    local code = game.PrivateServerId
    print("You are in a private server!")
    print("Private server ID: " .. code)
    local joinLink = ("https://www.roblox.com/games/%d?privateServerLinkCode=%s"):format(placeId, code)
    print("Join link: " .. joinLink)
else
    print("Not in a private server.")
end
