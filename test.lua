local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local placeId = game.PlaceId
local MAX_PLAYERS_IN_TARGET = 1
local ERROR_WAIT = 2

local q = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local scriptToQueue = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Loader/refs/heads/main/test.lua"))()]]

-- Find a low-pop server, skipping current server
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
                if server.id ~= game.JobId and server.playing and server.playing <= MAX_PLAYERS_IN_TARGET then
                    if server.playing < bestCount then
                        bestServer = server
                        bestCount = server.playing
                        -- Don't return immediately, try to get the lowest pop
                    end
                end
            end
            if result.nextPageCursor then
                cursor = result.nextPageCursor
            else
                break
            end
        else
            warn("Failed to fetch server list. Waiting before retrying...")
            task.wait(ERROR_WAIT)
        end
    end
    return bestServer
end

-- Teleport and handle GameFull retry
local function safeTeleportLoop()
    local attempts = 0
    local maxAttempts = 10
    while attempts < maxAttempts do
        local targetServer = findLowPopServer()
        if not targetServer then
            warn("No suitable public server found. Please try again later.")
            return
        end

        warn("Attempting teleport to JobID:", targetServer.id)
        if q then
            q(scriptToQueue)
        end

        local teleportFailed = false
        local connection
        connection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
            warn("Teleport failed: " .. tostring(errorMessage))
            if teleportResult == Enum.TeleportResult.GameFull then
                warn("Target server is full, retrying another server...")
                teleportFailed = true
            else
                warn("Teleport failed for another reason: " .. tostring(teleportResult))
            end
            if connection then connection:Disconnect() end
        end)

        TeleportService:TeleportToPlaceInstance(placeId, targetServer.id, Players.LocalPlayer)
        -- Wait for teleport or failure
        local timeout = 10
        while timeout > 0 and not teleportFailed do
            task.wait(1)
            timeout = timeout - 1
        end

        -- If teleport failed due to full server, try next
        if teleportFailed then
            attempts = attempts + 1
            warn("Retrying... ("..attempts.."/"..maxAttempts..")")
            task.wait(1)
        else
            break -- Teleport initiated or succeeded, exit loop
        end
    end
    if attempts >= maxAttempts then
        warn("Failed to find a non-full server after multiple attempts.")
    end
end

-- Main detection loop, every 3 seconds
local loaderLoaded = false
while true do
    local currentPlayers = #Players:GetPlayers()
    if currentPlayers > MAX_PLAYERS_IN_TARGET then
        warn("Detected "..currentPlayers.." players in server! (target is "..MAX_PLAYERS_IN_TARGET..") Serverhopping...")
        safeTeleportLoop()
        break
    else
        if not loaderLoaded then
            warn("You are in a server with "..currentPlayers.." player(s). Running loader.")
            local success, result = pcall(function()
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Loader/refs/heads/main/test.lua"))()
            end)
            print("Loader script executed!", success, result)
            loaderLoaded = true
        end
        task.wait(5) -- Wait 5 seconds before next check to avoid spamming
    end
end
