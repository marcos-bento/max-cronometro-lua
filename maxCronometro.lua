-- Criando a janela do cronômetro
local frame = CreateFrame("Frame", "MaxCronometroFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(190, 100)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)


local titleText = "MaxCronometro!"
local elapsedTime = 0
local timeIcon = "|TInterface\\Icons\\INV_Misc_PocketWatch_02:12:12:0:0|t"
local isRunning = false
local goldEarned = 0
local silverEarned = 0
local copperEarned = 0
local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:0:0|t"
local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:0:0|t"
local copperIcon = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:0:0|t"
local expGained = 0
local itensLooted = 0
local questCount = 0
local monsterKillCount = 0
local expBeforeFight = 0
local expAfterFight = 0
local totalMoneyBeforeTransaction = 0

-- Adicionando um título à janela
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", frame, "TOP", 0, -5)
title:SetText(titleText)

-- Adicionando um texto para exibir o tempo
local timerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
timerText:SetPoint("CENTER", frame, "CENTER", 0, 15)
timerText:SetText(timeIcon .. " 00:00")

-- Adicionando um texto para exibir o gold adquirido
local goldText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldText:SetPoint("CENTER", frame, "CENTER", 0, -2)
goldText:SetText(goldIcon .. goldEarned .. " " .. silverIcon .. silverEarned .. " " .. copperIcon .. copperEarned)

local function drawMoney()
	if copperEarned > 100 then
		copperEarned = copperEarned - 100
		silverEarned = silverEarned + 1
	end
	
	if silverEarned > 100 then
		silverEarned = silverEarned - 100
		goldEarned = goldEarned + 1
	end

	goldText:SetText(goldIcon .. goldEarned .. " " .. silverIcon .. silverEarned .. " " .. copperIcon .. copperEarned)
end

-- Adicionando botões de controle
local playButton = CreateFrame("Button", "MaxCronometroPlayButton", frame, "UIPanelButtonTemplate")
playButton:SetSize(50, 25)
playButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
playButton:SetText("Play")
playButton:SetScript("OnClick", function(self)
    if not isRunning then
        print("MaxCronômetro iniciado!")
        isRunning = true
    end
end)

local pauseButton = CreateFrame("Button", "MaxCronometroPauseButton", frame, "UIPanelButtonTemplate")
pauseButton:SetSize(50, 25)
pauseButton:SetPoint("LEFT", playButton, "RIGHT", 10, 0)
pauseButton:SetText("Pause")
pauseButton:SetScript("OnClick", function(self)
    -- Lógica para pausar o cronômetro
    print("MaxCronômetro pausado!")
    isRunning = false
end)

local stopButton = CreateFrame("Button", "MaxCronometroStopButton", frame, "UIPanelButtonTemplate")
stopButton:SetSize(50, 25)
stopButton:SetPoint("LEFT", pauseButton, "RIGHT", 10, 0)
stopButton:SetText("Stop")
stopButton:SetScript("OnClick", function(self)
    -- Lógica para parar o cronômetro
    local minutes = math.floor(elapsedTime / 60)
    local seconds = elapsedTime % 60
    print("MaxCronômetro parado!")
    print("Tempo decorrido: ", string.format("%02d", minutes), "minutos e", string.format("%02d", seconds), "segundos")
    print("Moedas coletadas:", goldEarned,goldIcon,silverEarned,silverIcon,copperEarned,copperIcon)
    print("Criaturas derrotadas:",monsterKillCount)
    print("Itens saqueados:",itensLooted)
    print("Experiência coletada:",expGained,"pontos")
    print("Missões finalizadas:",questCount)
	goldEarned = 0
	silverEarned = 0
	copperEarned = 0
    expGained = 0
    itensLooted = 0
    questCount = 0
    monsterKillCount = 0
	drawMoney()
	elapsedTime = 0
    isRunning = false
    timerText:SetText(timeIcon .. " 00:00")
end)

-- Função para atualizar o tempo exibido no cronômetro
local function UpdateTimerDisplay()
    local minutes = math.floor(elapsedTime / 60)
    local seconds = elapsedTime % 60
    timerText:SetText(timeIcon .. " " .. string.format("%02d:%02d", minutes, seconds))
end

frame:SetScript("OnUpdate", function(self, elapsed)
    if isRunning then
        elapsedTime = elapsedTime + elapsed
        UpdateTimerDisplay()
        playButton:Disable()
        pauseButton:Enable()
        stopButton:Enable()
    else
        playButton:Enable()
        pauseButton:Disable()
        if elapsedTime == 0 then
            stopButton:Disable()
        end
    end
end)

--###################################################
-- Trecho de código que lidará com o Gold ganho
--###################################################

local frame = CreateFrame("Frame")

-- Lidando com SAQUE DE MOBS
-- --------------------------
frame:RegisterEvent("LOOT_OPENED")

-- Função para lidar com eventos de abertura de loot
local function HandleLootOpenedEvent(self, event, ...)
    local numItems = GetNumLootItems()
    if numItems > 0 and isRunning then
        -- Se houver itens no loot, verifique o dinheiro saqueado
        for i = 1, numItems do
            local lootType, ouroString, qty = GetLootSlotInfo(i)
            if lootType == 133784 then --Saqueou ouro
				local ouro, prata, cobre = ouroString:match("(%d+)%s*de%s*Ouro%s*(%d+)%s*de%s*Prata%s*(%d+)%s*de%s*Cobre")
				-- Converta os valores para números inteiros
				goldEarned = goldEarned + tonumber(ouro)
				silverEarned = silverEarned + tonumber(prata)
				copperEarned = copperEarned + tonumber(cobre)
				drawMoney()
			elseif lootType == 133787 then --Saqueou prata
				local prata, cobre = ouroString:match("(%d+)%s*de%s*Prata%s*(%d+)%s*de%s*Cobre")
				-- Converta os valores para números inteiros
				silverEarned = silverEarned + tonumber(prata)
				copperEarned = copperEarned + tonumber(cobre)
				drawMoney()
            elseif lootType == 133789 then --Saqueou cobre
                local cobre = ouroString:match("(%d+)%s*de%s*Cobre")
                copperEarned = copperEarned + tonumber(cobre)
                drawMoney()
            else
                -- #########################
                -- Opção 1: Itens saqueados de forma agrupada EX: Loot de 5 sedas = 1 unidade
                itensLooted = itensLooted + 1
                -- #########################
                -- #########################
                -- Opção 2: Itens saqueados de forma individual EX: Loot de 5 sedas = 5 unidades
                -- itensLooted = itensLooted + qty
                -- #########################
            end
        end
    end
end

-- Lidando com VENDEDORES
-- ----------------------

-- Adicione os eventos MERCHANT_SHOW e MERCHANT_CLOSED
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")

local function UpdateMoneyEarned()
	if isRunning then
		local moneyDiff = GetMoney() - totalMoneyBeforeTransaction
		
		if moneyDiff > 0 then
			
			local goldFromTransaction = math.floor(moneyDiff / 10000)
			local silverFromTransaction = math.floor((moneyDiff % 10000) / 100)
			local copperFromTransaction = moneyDiff % 100

			goldEarned = goldEarned + goldFromTransaction
			silverEarned = silverEarned + silverFromTransaction
			copperEarned = copperEarned + copperFromTransaction

			drawMoney()
		end
	end
end

-- Lidando com recompensa de quest
-- -------------------------------

frame:RegisterEvent("QUEST_TURNED_IN")

local function HandleQuestTurnedInEvent(self, event, questID, experience, money)
    if isRunning then
        questCount = questCount + 1
        if money > 0 then
			local goldFromQuest = math.floor(money / 10000)
			local silverFromQuest = math.floor((money % 10000) / 100)
			local copperFromQuest = money % 100
			goldEarned = goldEarned + goldFromQuest
			silverEarned = silverEarned + silverFromQuest
			copperEarned = copperEarned + copperFromQuest
			drawMoney()
		end
        if experience > 0 then
            expEarned = expEarned + experience
        end
    end
end

-- Lidando com a experiencia recebida em combate
-- ---------------------------------------------

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

function HandleCombatLogEvent(self, event, ...)
    if isRunning then
        local timestamp, subevent = CombatLogGetCurrentEventInfo()
        if subevent == "PARTY_KILL" then
            monsterKillCount = monsterKillCount + 1
            expBeforeFight = UnitXP("player")
        end
    end
end

frame:RegisterEvent("PLAYER_XP_UPDATE")

function handleExpUpdate(self, event, ...)
    if isRunning then
        expAfterFight = UnitXP("player")
        expGained = expGained + (expAfterFight - expBeforeFight)
        expBeforeFight = expAfterFight
    end
end

-- Lidando com a Gold recebido de correios
-- ---------------------------------------

frame:RegisterEvent("MAIL_SHOW")

-- Função que executa quando o jogador fechar a janela do correios
local function OnMailFrameClosed()
    if isRunning then
        UpdateMoneyEarned()
    end
end
  
-- Registramos um evento para ser acionado quando a tela do correio for fechada
MailFrame:HookScript("OnHide", OnMailFrameClosed)

-- #######################################################

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "MERCHANT_SHOW" then
        totalMoneyBeforeTransaction = GetMoney()
    elseif event == "MERCHANT_CLOSED" then
        UpdateMoneyEarned()
    elseif event == "MAIL_SHOW" then
        totalMoneyBeforeTransaction = GetMoney()
    elseif event == "LOOT_OPENED" then
        HandleLootOpenedEvent(self, event, ...)
    elseif event == "QUEST_TURNED_IN" then
        HandleQuestTurnedInEvent(self, event, ...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        HandleCombatLogEvent(self, event, ...)
    elseif event == "PLAYER_XP_UPDATE" then
        handleExpUpdate(self, event, ...)
    end
end)

-- #######################################################

-- Comandos de chat para mostrar/esconder a janela
SLASH_MAXCRONOMETRO1 = "/maxCronometro"
SlashCmdList["MAXCRONOMETRO"] = function(msg)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end