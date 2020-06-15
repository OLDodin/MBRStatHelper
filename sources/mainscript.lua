local m_reactions={}
local m_configForm = nil
local m_template = nil
local m_mWdg = nil
local m_rWdg = nil
local m_bWdg = nil
local m_critWdg = nil
local m_amuletInfo = nil
local m_shopCheckBox = nil
local m_alhimCheckBox = nil
local m_ordenCheckBox = nil
local m_rEditLine = nil
local m_eatRCheckBox = nil
local m_guildCritCheckBox = nil
local m_diffWdg = nil

local MAX_HP = 10000

function AddReaction(name, func)
	if not m_reactions then m_reactions={} end
	m_reactions[name]=func
end

function RunReaction(widget)
	local name=getName(widget)
	if not name or not m_reactions or not m_reactions[name] then return end
	m_reactions[name]()
end

function ButtonPressed(params)
	RunReaction(params.widget)
	changeCheckBox(params.widget)
end

function ChangeMainWndVisible()
	if isVisible(m_configForm) then
		hide(m_configForm)
	else
		show(m_configForm)
	end
	setLocaleText(m_mWdg)
	setLocaleText(m_rWdg)
	setLocaleText(m_bWdg)
	setLocaleText(m_critWdg)
	setLocaleText(m_diffWdg)
end

local function GetTimestamp()
	return common.GetMsFromDateTime( common.GetLocalDateTime() )
end

local function floor_to_step(aNum, aStep)
   return math.floor(aNum/aStep+0.5)*aStep
end

local function CalcDD(aM, aR, aB, aCrit, aRLvl)
	return (1+0.0005*aM)*(1+0.0005*aB)*(1+0.00075*aRLvl*aR)*(1+0.0004*aCrit)
end


local function CalcDDByHp(aM, aR, aB, aCrit, aRLvl, aHP)
	return (1+0.0005*aM)*(1+(0.001 + 0.00000012852*aB)*(1-aHP/MAX_HP)*aB)*(1+0.00075*aRLvl*aR)*(1+0.0004*aCrit)
end

local function CalcKillTime(aM, aR, aB, aCrit, aRLvl)
	local currHP = MAX_HP
	local killTime = 0
	while currHP > 0 do
		currHP = currHP - CalcDDByHp(aM, aR, aB, aCrit, aRLvl, currHP)
		killTime = killTime + 1
	end
	
	return killTime
end


local function CheckPercentVal(aVal, aDefaultVal, aWdg)
	if not aVal or aVal < 0 or aVal > 100 then
		aVal = aDefaultVal
		setText(aWdg, tostring(aVal))
	end
	return aVal
end

function CalcPressed()
	local currMaster = 0
	local currResh = 0
	local currBesp = 0
	local currCrit = 0
	
	local stats = avatar.GetInnateStats()
	for i = 0, GetTableSize( stats ) - 1 do
		local stat = stats[i]
		if stat.sysName == "ENUM_InnateStats_Plain" then
			currMaster = stat.effective-stat.buffs
		end
		if stat.sysName == "ENUM_InnateStats_Rage" then
			currResh = stat.effective-stat.buffs
		end
		if stat.sysName == "ENUM_InnateStats_Finisher" then
			currBesp = stat.effective-stat.buffs
		end
	end

	local specStats = avatar.GetSpecialStats()
	for i = 1, GetTableSize( specStats ) do
		if toString(specStats[i].name) == "Удача" then 
			currCrit = specStats[i].effective-specStats[i].buffs
			break
		end
	end

	
	local amuletBonus = 0
	local myDressedSlots = unit.GetEquipmentItemIds(avatar.GetId(), ITEM_CONT_EQUIPMENT) 
	local amulet = myDressedSlots[DRESS_SLOT_TRINKET]
	if amulet then
		local itemQuality = itemLib.GetQuality( amulet )
		local quality = itemQuality and itemQuality.quality
		--150 200 230 250 270 к мастерству раз в 60с на 15с + некоторое время на срабатывание 10-25%
		if quality == ITEM_QUALITY_UNCOMMON then
			amuletBonus = 30
		elseif quality == ITEM_QUALITY_RARE then
			amuletBonus = 45
		elseif quality == ITEM_QUALITY_EPIC then
			amuletBonus = 51
		elseif quality == ITEM_QUALITY_LEGENDARY then
			amuletBonus = 60
		elseif quality == ITEM_QUALITY_RELIC then
			amuletBonus = 65
		end
	end
	
	local rLevelTxt = getText(m_rEditLine)
	local rLevelVal = tonumber(rLevelTxt)
	rLevelVal = CheckPercentVal(rLevelVal, 95, m_rEditLine)
	
	rLevelVal = rLevelVal / 100
	
	local useShop = getCheckBoxState(m_shopCheckBox)
	local useOrden = getCheckBoxState(m_ordenCheckBox)
	local useAlhim = getCheckBoxState(m_alhimCheckBox)
	local useEatR = getCheckBoxState(m_eatRCheckBox)
	local useGuildCrit = getCheckBoxState(m_guildCritCheckBox)
	local summaStat = currMaster+currResh+currBesp+currCrit+amuletBonus
	if useShop then 
		summaStat = summaStat + 100
	end	
	if useAlhim then
		summaStat = summaStat + 50
	end
	
	local maxRes = {}
	maxRes.value = 0
	maxRes.m = 0
	maxRes.r = 0
	maxRes.b = 0
	maxRes.crit = 0
	
	local step = 10

	for m=amuletBonus, summaStat, step do
		for b=0, summaStat-m, step do
			for crit=0, summaStat-m-b, step do
				local r = summaStat-b-m-crit
				if useOrden then
					r = r + 100
				end
				if useEatR then
					r = r + 25
				end
				if useGuildCrit then
					crit = crit + 40
				end
				local res = CalcDD(m, r, b, crit, rLevelVal)
				if res > maxRes.value then
					maxRes.value = res
					maxRes.m = m
					maxRes.r = r
					maxRes.b = b
					maxRes.crit = crit
				end
			end
		end
	end

	--LogInfo("find res = ", maxRes.value, " myCurrRes = ", myCurrRes, " m= ", maxRes.m, " r= ", maxRes.r, " b= ", maxRes.b)

	local currValue = CalcDD(currMaster, currResh, currBesp, currCrit, rLevelVal)	
	local diff = floor_to_step((maxRes.value/currValue-1)*100, 0.001)
	
	setText(m_mWdg, tostring(math.floor(maxRes.m-amuletBonus)))
	setText(m_rWdg, tostring(math.floor(maxRes.r)))
	setText(m_bWdg, tostring(math.floor(maxRes.b)))
	setText(m_critWdg, tostring(math.floor(maxRes.crit)))
	setText(m_diffWdg, tostring(diff).."%", "ColorGreen")
	
	
	if amuletBonus > 0 then
		setText(m_amuletInfo, getLocale()["amuletInfo"]..tostring(amuletBonus), "ColorGray")
	else
		setText(m_amuletInfo, "")
	end
end


function InitConfigForm()
	setTemplateWidget(m_template)
	local formWidth = 500
	local form=createWidget(mainForm, "ConfigForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, formWidth, 500, 100, 120)
	priority(form, 5500)
	hide(form)
	local grShiftX = 25
	local grShiftY = 140

	local btnWidth = 220
	
	setLocaleText(createWidget(form, "calcButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, btnWidth, 25, formWidth/2-btnWidth/2, 470))

	local descWdg = createWidget(form, "desc", "TextView", nil, nil, formWidth-25*2, 200, 25, 30)
	setLocaleText(descWdg)
	descWdg:SetMultiline(true)
	
	setLocaleText(createWidget(form, "lineM", "TextView", nil, nil, 600, 25, grShiftX, grShiftY))
	setLocaleText(createWidget(form, "lineR", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30))
	setLocaleText(createWidget(form, "lineB", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30*2))
	setLocaleText(createWidget(form, "lineCrit", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30*3))
	setLocaleText(createWidget(form, "lineDiff", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30*5))
	

	m_mWdg = createWidget(form, "resM", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY)
	m_rWdg = createWidget(form, "resR", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30)
	m_bWdg = createWidget(form, "resB", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30*2)
	m_critWdg = createWidget(form, "resCrit", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30*3)
	m_diffWdg = createWidget(form, "resDiff", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30*5)
	
	m_amuletInfo = createWidget(form, "amuletInfo", "TextView", nil, nil, formWidth-grShiftX*2, 60, grShiftX, grShiftY+30*3+15)
	m_amuletInfo:SetMultiline(true)
	
	m_guildCritCheckBox = createWidget(form, "useGuildCrit", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 335)
	m_eatRCheckBox = createWidget(form, "useEatR", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 360)
	m_alhimCheckBox = createWidget(form, "useAlhim", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 385)
	m_shopCheckBox = createWidget(form, "useShop", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 410)
	m_ordenCheckBox = createWidget(form, "useOrden", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 435)
	setCheckBox(m_guildCritCheckBox, false)
	setCheckBox(m_eatRCheckBox, false)
	setCheckBox(m_shopCheckBox, false)
	setCheckBox(m_ordenCheckBox, false)
	setCheckBox(m_alhimCheckBox, false)
	
	local wdg = createWidget(form, "amountOfR", "TextView", nil, nil, 160, 60, grShiftX, 410)
	wdg:SetMultiline(true)
	setLocaleText(wdg)
	m_rEditLine = createWidget(form, "EditLine1", "EditLine", nil, nil, 40, 25, 90, 424, nil, nil)
	setText(m_rEditLine, "95")
	
	setLocaleText(m_guildCritCheckBox)
	setLocaleText(m_eatRCheckBox)
	setLocaleText(m_shopCheckBox)
	setLocaleText(m_ordenCheckBox)
	setLocaleText(m_alhimCheckBox)
	setLocaleText(m_mWdg)
	setLocaleText(m_rWdg)
	setLocaleText(m_bWdg)
	setLocaleText(m_critWdg)
	setLocaleText(m_diffWdg)


	setText(createWidget(form, "closeBarsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 14), "x")
	DnD:Init(form, form, true)
	AddReaction("closeBarsButton", function () ChangeMainWndVisible() end)
	
	AddReaction("calcButton", CalcPressed)
	
	return form
end


function Init()
	m_template = createWidget(nil, "Template", "Template")
	setTemplateWidget(m_template)
		
	local button=createWidget(mainForm, "AORBMButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 50, 25, 300, 120)
	setText(button, "MBR")
	DnD:Init(button, button, true)
	
	common.RegisterReactionHandler(ButtonPressed, "execute")

	m_configForm = InitConfigForm()
	
	AddReaction("AORBMButton", function () ChangeMainWndVisible() end)
	common.RegisterEventHandler( onAOPanelStart, "AOPANEL_START" )
	common.RegisterEventHandler( onAOPanelLeftClick, "AOPANEL_BUTTON_LEFT_CLICK" )
	common.RegisterEventHandler( onAOPanelRightClick, "AOPANEL_BUTTON_RIGHT_CLICK" )
	common.RegisterEventHandler( onAOPanelChange, "EVENT_ADDON_LOAD_STATE_CHANGED" )
end

if (avatar.IsExist()) then
	Init()
else
	common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")
end