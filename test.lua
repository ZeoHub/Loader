-- 1. Load your remote script first
loadstring(game:HttpGet("https://get.nathub.xyz/loader"))()

-- 2. (Optional) Queue a script to run after teleport
local q = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if q then
    q([[loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Loader/refs/heads/main/test.lua"))()]]) -- Change URL if needed
end

-- 3. Teleport to the desired place
local PLACE_ID = 126884695634066 -- Change this to your desired PlaceId
game:GetService("TeleportService"):Teleport(PLACE_ID)

-- 4. Detect if you are in a private server
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
