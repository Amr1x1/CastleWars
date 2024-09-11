print("Castle Wars script")

local API = require("api")
local UTILS = require("utils")
local firstTime = true
local totalGames = 0



local function isObjectThere(id)
    if API.GetAllObjArray1({ id }, 10, {0, 12})[1] ~= nil then
        return true
    end
end

local function waitForObject(id, type)
    while API.Read_LoopyLoop() and API.GetAllObjArray1({ id }, 50, {type})[1] == nil do
        API.RandomSleep2(600, 600, 600)
    end
end

local function waitBankOpen()
    while API.Read_LoopyLoop() and not API.Compare2874Status(24, false) do
        API.RandomSleep2(600, 600, 600)
    end
end

local function waitBankClosed()
    while API.Read_LoopyLoop() and API.Compare2874Status(24, false) do
        API.RandomSleep2(600, 600, 600)
    end
end

local function waitForVB(number)
    while API.Read_LoopyLoop() and not API.Compare2874Status(number, false) do
        API.RandomSleep2(600, 600, 600)
    end
end



local function waitForXpTick(skillName)
    local currentXp = API.GetSkillXP(skillName)
    local waitTime = 20
    local exitLoop = false
    local start = os.time()
    while not exitLoop and os.time() - start < waitTime do
        API.RandomSleep2(100,0,0)
        local loopXp = API.GetSkillXP(skillName)
        if math.abs(loopXp - currentXp) > 0 then
            exitLoop = true
            return true
        end
        if not API.Read_LoopyLoop() then
            exitLoop = true
            return false
        end
        if not API.PlayerLoggedIn() then
            exitLoop = true
            return false
        end
    end
end


local function run_to_tile(x, y, z)
    math.randomseed(os.time())

    rand1 = math.random(-1, 1)
    rand2 = math.random(-1, 1)
    local tile = WPOINT.new(x + rand1, y + rand2, z)

    API.DoAction_WalkerW(tile)

    local threshold = math.random(5, 8)
    while API.Read_LoopyLoop() and API.Math_DistanceW(API.PlayerCoord(), tile) > threshold do
        API.RandomSleep2(200, 200, 200)
    end
end

local function gameStateChecks()
    if not API.Read_LoopyLoop() or not API.PlayerLoggedIn() then
        API.Write_LoopyLoop(false)
        return false
    end
    return true 
end

local IDS = {
    GUTHIX_PORTAL = 83642,
    BANK_CHEST = 83634,
    EXIT_PORTAL_SARA = 83510,
    EXIT_PORTAL_ZARA = 83620,
    WAITING_ROOM = 74979,
    ZAMMY_DOOR = 83570, --12
    SARA_DOOR = 83496,
    ZAMMY_LADDER = 83622,
    SARA_LADDER = 83511,
}

local function getAllIDSValues()
    local idsList = {}
    for _, id in pairs(IDS) do
        table.insert(idsList, id)
    end
    return idsList
end



local function inCastleWars()
    return API.GetAllObjArray1({ table.unpack(getAllIDSValues()) }, 50, {0, 12})[1] ~= nil
end

local function isInCastleWarsLobby()
    return not isObjectThere(IDS.WAITING_ROOM) and isObjectThere(IDS.BANK_CHEST)
end

local function goGuthixPortal()
    if isInCastleWarsLobby() and gameStateChecks() then

        if API.Compare2874Status(18, false) then
            API.DoAction_Interface(0xffffffff,0xffffffff,1,985,88,-1,API.OFF_ACT_GeneralInterface_route)
            totalGames = totalGames + 1
            print("Total games: " .. totalGames)
            API.RandomSleep2(800, 600, 600)
        end
        
        API.DoAction_Object1(0x39,API.OFF_ACT_GeneralObject_route0,{ IDS.GUTHIX_PORTAL },50)
        print("Entering portal")
        if API.Compare2874Status(18, false) then return end
        while gameStateChecks() and not isObjectThere(IDS.WAITING_ROOM) do
            API.RandomSleep2(600, 600, 600)
        end
        print("Waiting for game...")
    end
end

local function isInSaraRespawnRoom()
    return API.PlayerCoord().x >= 2423 and API.PlayerCoord().y < 3081
end

local function isInZammyRespawnRoom()
    return API.PlayerCoord().x < 2377 and API.PlayerCoord().y > 3126
end


local function ZammyDoor()
    if gameStateChecks() then
        API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{ IDS.ZAMMY_DOOR },50)
        while gameStateChecks() and isInZammyRespawnRoom() do
            API.RandomSleep2(600, 600, 600)
        end
        print("out")
    end
end

local function ZammyLadder()
    if gameStateChecks() then
        API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{ IDS.ZAMMY_LADDER },50)
        while gameStateChecks() and API.PlayerCoord().z == 1 do
            API.RandomSleep2(600, 600, 600)
        end
        print("Climbed up")
    end
end

local function SaraDoor()
    if gameStateChecks() then
        API.DoAction_Object1(0x39,API.OFF_ACT_GeneralObject_route0,{ IDS.SARA_DOOR },50)
        while gameStateChecks() and isInSaraRespawnRoom() do
            API.RandomSleep2(600, 600, 600)
        end
        print("out")
    end
end

local function SaraLadder()
    if gameStateChecks() then
        API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{ IDS.SARA_LADDER },50)
        while gameStateChecks() and API.PlayerCoord().z == 1 do
            API.RandomSleep2(600, 600, 600)
        end
        print("Climbed up")
    end
end



local function isInsideGame()
    return isObjectThere(IDS.ZAMMY_LADDER) or isObjectThere(IDS.SARA_LADDER)
end



API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------



if not inCastleWars() and firstTime then
    print("Please go to Castle Wars")
    API.Write_LoopyLoop(false)
    break
end
firstTime = false

if isInCastleWarsLobby() then
    goGuthixPortal()
end

if isObjectThere(IDS.WAITING_ROOM) and tonumber(API.Dialog_Option("Yes, please!")) then
    API.Select_Option("Yes, please!")
    API.RandomSleep2(800,600,600)
end



if isInsideGame() then
    math.randomseed(os.time())
    local number = math.random(1, 4)
    if isObjectThere(IDS.SARA_LADDER) and isInSaraRespawnRoom() and API.PlayerCoord().z == 1 then
        print("Game started")
        if number ~= 2 then
            SaraLadder()
        else
            SaraDoor()
        end
    elseif isObjectThere(IDS.ZAMMY_LADDER) and isInZammyRespawnRoom() and API.PlayerCoord().z == 1 then
        print("Game started")
        math.randomseed(os.time())
        if number ~= 4 then
            ZammyLadder()
        else
            ZammyDoor()
        end
    end
end



UTILS:antiIdle()



API.RandomSleep2(1800, 1000, 5000)
end----------------------------------------------------------------------------------
