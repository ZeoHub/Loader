local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local placeId = game.PlaceId
local currentJobId = game.JobId
local MAX_PLAYERS_IN_TARGET = 1 -- Only want to stay in solo servers

local function findLowPopServer()
    local bestServer = nil
    local bestCount = math.huge
    local cursor = ""
    for i = 1, 10 do
        local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= currentJobId and server.playing and server.maxPlayers and server.playing <= MAX_PLAYERS_IN_TARGET then
                    if server.playing < bestCount then
                        bestServer = server
                        bestCount = server.playing
                        return bestServer
                    end
                end
            end
            if result.nextPageCursor then
                cursor = result.nextPageCursor
            else
                break
            end
        else
            warn("Failed to fetch server list. Hit rate limit or error. Waiting before retrying...")
            task.wait(2)
        end
    end
    return bestServer
end

local q = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local scriptToQueue = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Loader/refs/heads/main/test.lua"))()]]

local function safeTeleport(placeId, jobId)
    if q then
        q(scriptToQueue)
    end
    TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
end

-- Loop to detect new players joining
while true do
    local currentPlayers = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers

    -- If someone else joined, hop
    if currentPlayers > MAX_PLAYERS_IN_TARGET then
        warn("Detected "..currentPlayers.." players in server! (target is "..MAX_PLAYERS_IN_TARGET..") Serverhopping...")
        local targetServer = findLowPopServer()
        if targetServer then
            safeTeleport(placeId, targetServer.id)
        else
            warn("No suitable public server found. Please try again later.")
        end
        break -- stop the loop after teleporting!
    else
        print("[Solo Server] Still alone! ("..currentPlayers..")")
    end
    task.wait(3)
end
