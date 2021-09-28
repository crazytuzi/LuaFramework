local FactionYSTLayer = class("FactionYSTLayer", require ("src/TabViewLayer") )
FactionYSTLayer.reload = nil

local path = "res/faction/"
local pathCommon = "res/common/"

--Íâ½»×´Ì¬
local SocialState = 
{
	Neutral = 0,		--ÖÐÁ¢
	ApplyUnion = 1,		--ÉêÇëÁªÃË
	Union = 2,		    --ÁªÃË
	Hostility = 3,		--µÐ¶Ô
}

--Íâ½»²Ù×÷
local SocialOperator = 
{	
	None = 0,
	ApplyUnion = 1,		--ÉêÇëÁªÃË
	AcceptUnion = 2,	--Í¬ÒâÁªÃË
	RefuseUnion = 3,	--¾Ü¾øÁªÃË
	StopUnion = 4,		--ÖÕÖ¹ÁªÃË
	ApplyHostility = 5,	--ÐûÕ½
	ServerSet = 6,		--·þÎñÆ÷ÉèÖÃ
}

function FactionYSTLayer:ctor(factionData, parentBg)
	local msgids = {FACTION_SC_GETSOCIALINFO_RET,FACTION_SC_SOCIALOPERATOR_RET}
	require("src/MsgHandler").new(self,msgids)

	g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETSOCIALINFO, "GetFactionSocialInfo", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
    addNetLoading(FACTION_CS_GETSOCIALINFO, FACTION_SC_GETSOCIALINFO_RET)
    

	self.data = {}
	self.job = factionData.job
	self.factionData = factionData
	self.baseNode = parentBg

    local infoBg = createScale9Frame(
		self.baseNode,
		"res/common/scalable/panel_outer_base_1.png",
		"res/common/scalable/panel_outer_frame_scale9_1.png",
		cc.p(0, 0),
		cc.size(710, 501),
		4
	)

 	local topBg = CreateListTitle(self.baseNode, cc.p(self.baseNode:getContentSize().width/2, 456), 702, 43, cc.p(0.5, 0))
 	local topStr = {
						{text=game.getStrByKey("factionYST_name"), pos=cc.p(100, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("factionYST_level"), pos=cc.p(220, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("factionYST_count"), pos=cc.p(320, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("factionYST_fight"), pos=cc.p(430, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("factionYST_oper"), pos=cc.p(580, topBg:getContentSize().height/2)},
					}
	self.topStr = topStr
	for i,v in ipairs(topStr) do
		createLabel(topBg, topStr[i].text, topStr[i].pos, cc.p(0.5, 0.5), 22, true)
	end
		
    self:createTableView(self.baseNode, cc.size(700, 455), cc.p(10, 1), true, true)
end

function FactionYSTLayer:reloadData()

end

function FactionYSTLayer:tableCellTouched(table,cell)

end

function FactionYSTLayer:cellSizeForTable(table,idx) 
    return 70, 730
end

function FactionYSTLayer:tableCellAtIndex(table, idx)
	local data = self.data[idx+1]
	if not data then 
		return
	end

    local cell = table:dequeueCell()
    local function createCell(cell)

        local getHoursText = function()
            local sec = data.coolTime - os.time()
            local hour = math.floor(sec/3600)
            if hour < 1 then
                hour = 1
            end
            local txt = tostring(hour)..game.getStrByKey("hours")
            return txt
        end

        local getMinuteText = function()
            local sec = data.coolTime - os.time()
            local min = math.floor(sec/60)
            if min < 1 then
                min = 1
            end
            local txt = tostring(min)..game.getStrByKey("minute")
            return txt
        end
    	
        local declareFunc = function()
		    local okFunc = function()
                local curTime = os.time()
                if (data.coolTime ~= nil and curTime < data.coolTime) then
                    local timeStr = nil
                    if data.coolTime > 120*60 then
                        timeStr = getHoursText()
                    else
                        timeStr = getMinuteText()
                    end
                    local txt = string.format(game.getStrByKey("factionYST_operError0"), timeStr)
                    TIPS({type = 1 , str=txt})
                    return
                end
                
                --·¢ËÍÐûÕ½Ð­Òé
                g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_SOCIALOPERATOR, "FactionSocialOperator", {opType=SocialOperator.ApplyHostility, srcFactionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), dstFactionID=data.Id})
            end
            
            MessageBoxYesNo(game.getStrByKey("factionYST_decalreFightTitle"), game.getStrByKey("factionYST_tips2"), okFunc, nil)
        end
        local alignFunc = function()
            local okFunc = function()
                local curTime = os.time()
                if (data.coolTime ~= nil and curTime < data.coolTime) then
                    local timeStr = nil
                    if data.coolTime > 120*60 then
                        timeStr = getHoursText()
                    else
                        timeStr = getMinuteText()
                    end
                    local txt = string.format(game.getStrByKey("factionYST_operError0"), timeStr)
                    TIPS({type = 1 , str=txt})
                    return
                end

                --·¢ËÍÁªÃËÐ­Òé
                g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_SOCIALOPERATOR, "FactionSocialOperator", {opType=SocialOperator.ApplyUnion, srcFactionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), dstFactionID=data.Id})
            end
            
            MessageBoxYesNo(game.getStrByKey("factionYST_alignTitle"), game.getStrByKey("factionYST_tips3"), okFunc, nil)
        end

        local stopFunc = function()
            local okFunc = function()
                --·¢ËÍÖÐÖ¹ÁªÃËÐ­Òé
                g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_SOCIALOPERATOR, "FactionSocialOperator", {opType=SocialOperator.StopUnion, srcFactionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), dstFactionID=data.Id})
            end
            
            local text = string.format(game.getStrByKey("factionYST_tips1"), data.name)
            MessageBoxYesNo(game.getStrByKey("factionYST_alignStopTitle"), text, okFunc, nil, game.getStrByKey("factionYST_stopAlign"), game.getStrByKey("factionYST_continueAlign"))
        end

        local procApplyFunc = function()
            local agreeFunc = function()
                --·¢ËÍÍ¬ÒâÁªÃËÐ­Òé
                g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_SOCIALOPERATOR, "FactionSocialOperator", {opType=SocialOperator.AcceptUnion, srcFactionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), dstFactionID=data.Id})
            end
            local refuseFunc = function()
                --·¢ËÍ¾Ü¾øÁªÃËÐ­Òé
                g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_SOCIALOPERATOR, "FactionSocialOperator", {opType=SocialOperator.RefuseUnion, srcFactionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), dstFactionID=data.Id})
            end

            local text = string.format(game.getStrByKey("factionYST_tips4"), data.name)
            MessageBoxYesNo(game.getStrByKey("factionYST_alignApplyTitle"), text, agreeFunc, refuseFunc, game.getStrByKey("factionYST_ok"), game.getStrByKey("factionYST_no"))
        end    

        local ldData = getFactionCapturedMap(data.Id) --获取领地数据
        local cellBg = createSprite(cell, "res/faction/sel_normal.png", cc.p(0,0), cc.p(0, 0))

        local ldIndex = 0
        if ldData[3] == 1 then
            ldIndex =3
        elseif ldData[2] == 1 then
            ldIndex =2
        elseif ldData[1] == 1 then
            ldIndex =1
        end
        
        print('ldIndex=============',ldIndex)
        local labelName = createLabel(cellBg, data.name, cc.p(self.topStr[1].pos.x, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.lable_black)
        if ldIndex> 0 then
             createSprite(cellBg, "res/faction/ld" .. ldIndex .. ".png", cc.p(4,cellBg:getContentSize().height/2), cc.p(0, 0.5))
         end
        createLabel(cellBg, tostring(data.level) .. game.getStrByKey("ji"), cc.p(self.topStr[2].pos.x, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.lable_black)
        createLabel(cellBg, tostring(data.count) .. "/" .. data.maxCount, cc.p(self.topStr[3].pos.x, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.lable_black)
        createLabel(cellBg, tostring(data.fightCount), cc.p(self.topStr[4].pos.x, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.lable_black)
    
        if self.job > 2 then
            if data.isAlign == true then
                local rep_menu = createMenuItem(cellBg, "res/component/button/62.png", cc.p(575, cellBg:getContentSize().height/2), stopFunc)
	            createLabel(rep_menu, game.getStrByKey("factionYST_haveAlign"),cc.p(rep_menu:getContentSize().width/2,rep_menu:getContentSize().height/2),nil, 20,true)
            elseif data.isFighting == true then
                local txt = game.getStrByKey("factionYST_fighting")
                if os.time() < data.coolTime then
                    txt = txt.." "..getMinuteText()
                end
                createLabel(cellBg, txt, cc.p(575, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.red)
            elseif data.isAlignApply == true then
                local rep_menu = createMenuItem(cellBg, "res/component/button/61.png", cc.p(575, cellBg:getContentSize().height/2), procApplyFunc)
	            createLabel(rep_menu, game.getStrByKey("factionYST_alignApply"),cc.p(rep_menu:getContentSize().width/2,rep_menu:getContentSize().height/2),nil, 20,true)
            elseif data.isAlignSelfApply == true then
                createLabel(cellBg, game.getStrByKey("factionYST_applyAligning"), cc.p(575, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.blue)
            else
                local rep_menu = createMenuItem(cellBg, "res/component/button/48.png", cc.p(520, cellBg:getContentSize().height/2), declareFunc)
	            createLabel(rep_menu, game.getStrByKey("factionYST_decalreFight"),cc.p(rep_menu:getContentSize().width/2,rep_menu:getContentSize().height/2),nil, 20,true)
	            local rep_menu = createMenuItem(cellBg, "res/component/button/61_sel.png", cc.p(630, cellBg:getContentSize().height/2), alignFunc)
	            createLabel(rep_menu, game.getStrByKey("factionYST_alignApply"),cc.p(rep_menu:getContentSize().width/2,rep_menu:getContentSize().height/2),nil, 20,true)
            end
        else
            if data.isAlign == true then
                createLabel(cellBg, game.getStrByKey("factionYST_haveAlign"), cc.p(575, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.lable_black)
            elseif data.isFighting == true then
                local txt = game.getStrByKey("factionYST_fighting")
                if os.time() < data.coolTime then
                    txt = txt.." "..getMinuteText()
                end
                createLabel(cellBg, txt, cc.p(575, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.red)
            elseif data.isAlignSelfApply == true then
                createLabel(cellBg, game.getStrByKey("factionYST_applyAligning"), cc.p(575, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.blue)
            else
                createLabel(cellBg, game.getStrByKey("factionYST_normal"), cc.p(575, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.lable_yellow)
            end
        end 
    end

    if nil == cell then
        cell = cc.TableViewCell:new()   
        createCell(cell)
    else
    	cell:removeAllChildren()
    	createCell(cell)
    end

    return cell
end

function FactionYSTLayer:numberOfCellsInTableView(table)
   	return #self.data
end

function FactionYSTLayer:networkHander(buff,msgid)
	local dealFunc = function (AId, BId, oper)
            local myFId = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID) 
            local destID = AId
            if AId == myFId then
                destID = BId
            end

            for j = 1, #self.data do
                if self.data[j].Id == destID then
                    self.data[j].isAlignApply = false
                    self.data[j].isAlignSelfApply = false
                    self.data[j].isAlign = false
                    self.data[j].isFighting = false  
                    
                    if oper == SocialOperator.ApplyUnion then
                        if myFId == AId then
                            self.data[j].isAlignSelfApply = true
                        else
                            self.data[j].isAlignApply = true
                        end
                    elseif oper == SocialOperator.ApplyHostility then
                        self.data[j].isFighting = true
                    elseif oper == SocialOperator.AcceptUnion then
                        self.data[j].isAlign = true
                    end

                    break
                end
            end	
    end
    
    local sortData = function ()
        local temp = {}
        for i = 1, #self.data do
            if self.data[i].isAlignApply == true then
                table.insert(temp, #temp+1, self.data[i])
            end
        end
        for i = 1, #self.data do
            if self.data[i].isFighting == true then
                table.insert(temp, #temp+1, self.data[i])
            end
        end
        for i = 1, #self.data do
            if self.data[i].isAlign == true then
                table.insert(temp, #temp+1, self.data[i])
            end
        end
        for i = 1, #self.data do
            if self.data[i].isAlignSelfApply == true then
                table.insert(temp, #temp+1, self.data[i])
            end
        end
        for i = 1, #self.data do
            if self.data[i].isAlignApply ~= true and self.data[i].isFighting ~= true and self.data[i].isAlign ~= true and self.data[i].isAlignSelfApply ~= true then
                table.insert(temp, #temp+1, self.data[i])
            end
        end

        self.data = temp
    end
   
    local switch = {
            [FACTION_SC_GETSOCIALINFO_RET] = function()    
			log("get FACTION_SC_GETSOCIALINFO_RET"..msgid)
			self.data = {} 

            local t = g_msgHandlerInst:convertBufferToTable("GetFactionSocialInfoRet", buff) 

            --ËùÓÐÐÐ»áÐÅÏ¢
            local myFId = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID) 
			local Num = #t.allFactions
			for i=1,Num do
				local record = {}
				record.Id = t.allFactions[i].id
                record.name = t.allFactions[i].name
				record.level = t.allFactions[i].lv
				record.count = t.allFactions[i].allMemberCnt
                record.maxCount = t.allFactions[i].maxMemberCnt
                record.fightCount = t.allFactions[i].totalAbility

                record.isAlign = false
                record.isFighting = false       
                record.isAlignApply = false
                record.isAlignSelfApply = false

                if myFId ~= record.Id then
				    table.insert(self.data, #self.data+1, record)
                end
			end

            --ÁªÃËÐÅÏ¢
            
            Num = #t.socials
			for i=1,Num do
				local AId = t.socials[i].aFactionID
                local BId = t.socials[i].bFactionID
                local state = t.socials[i].state
                local operId = t.socials[i].opFactionID
                local time = t.socials[i].time

                local destID = AId
                if AId == myFId then
                    destID = BId
                end

                for j = 1, #self.data do
                    if self.data[j].Id == destID then
                        self.data[j].coolTime = time + os.time()
                        if state == SocialState.ApplyUnion then
                            if operId == destID then
                                self.data[j].isAlignApply = true
                            else
                                self.data[j].isAlignSelfApply = true
                            end
                        elseif state == SocialState.Union then
                            self.data[j].isAlign = true
                        elseif state == SocialState.Hostility then
                            self.data[j].isFighting = true
                        end
                        
                        break
                    end
                end			
			end

            sortData()
			self:getTableView():reloadData()	
		end,

        --²Ù×÷·µ»Ø
        [FACTION_SC_SOCIALOPERATOR_RET] = function()    
			log("get FACTION_SC_SOCIALOPERATOR_RET"..msgid)
            local t0 = g_msgHandlerInst:convertBufferToTable("FactionSocialOperatorRet", buff) 

			local errorId = t0.retCode
            local oper = t0.opType
            local AId = t0.srcFactionID
            local BId = t0.dstFactionID

            --´íÎóÂð´¦Àí
            if errorId > 0 then
                local t = {game.getStrByKey("factionYST_operError1"), 
                           game.getStrByKey("factionYST_operError2"),
                           game.getStrByKey("factionYST_operError3"),
                           game.getStrByKey("factionYST_operError4"),
                           game.getStrByKey("factionYST_operError5"),
                           game.getStrByKey("factionYST_operError6"),
                           game.getStrByKey("factionYST_operError7"),
                           game.getStrByKey("factionYST_operError8"),
                           game.getStrByKey("factionYST_operError9"),
                           game.getStrByKey("factionYST_operError10"),
                           game.getStrByKey("factionYST_operError11"),
                           game.getStrByKey("factionYST_operError12") }
                
                if t[errorId] ~= nil then
                    TIPS({type = 1 , str=t[errorId]})
                end

                return
            end 

            dealFunc(AId, BId, oper)
            sortData()
			self:getTableView():reloadData()

      --[[      if SocialOperator.ApplyUnion == oper then
                TIPS({type = 1 , str=game.getStrByKey("factionYST_operSucc2")}) 
            elseif SocialOperator.ApplyHostility == oper then
                TIPS({type = 1 , str=game.getStrByKey("factionYST_operSucc1")}) 
            end   
            ]]             	
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionYSTLayer