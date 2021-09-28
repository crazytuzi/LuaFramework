
XiakeMng = {
	m_vXiakes      = {}; --xiakes

--xia ke jiu guan
	m_vJiuguanInfos= {}; --jiuguaninfo{key,value}

--wode xiake
	m_MaterialXiakeToBeDelete = nil;

--zhan dou pai xu
    m_vBattleOrder = {0,0,0,0}; --size == 4;
    m_vBattleOrder_yuanzheng = {}; --size == 4;
	m_iZhenRong = 1;

--xiake qiyu
    m_iXiayi       = 0;
    m_vXinwu       = {}; --xinwu{id, count}

	ePriceXiake = {x10 = 10, x100 = 50, x1000 = 95};

    m_b10Chg = false;
	m_b100Chg = false;
	m_b1000Chg = false;

	m_i10Left = 0;
	m_i10Time = -1,
	m_i100Time = -1,
	m_i1000Time = -1,

	eLvImages = {"set:MainControl7 image:NPCLevel1",
				"set:MainControl7 image:NPCLevel2",
				"set:MainControl7 image:NPCLevel3"};

	eXiakeFrames = {"set:MainControl12 image:NPCbackwhite",
					"set:MainControl12 image:NPCbackgreen",
					"set:MainControl12 image:NPCbackblue",
					"set:MainControl12 image:NPCbackpurple",
					"set:MainControl12 image:NPCbackorange",
					"set:MainControl12 image:NPCbackgold",
					"set:MainControl7 image:NPCbackpink",
					"set:MainControl7 image:NPCbackred",
					},
	
	ePinZhiImgs = {"set:MainControl7 image:1",
					"set:MainControl7 image:2",
					"set:MainControl7 image:3",
					"set:MainControl7 image:4",
					"set:MainControl7 image:5",
					"set:MainControl7 image:6",
					"set:MainControl7 image:7",
					"set:MainControl7 image:8",
					},

	eSkillFrames = {{imageset = "BaseControl1", image = "SkillInCell1"},
					{imageset = "BaseControl1", image = "SkillInCell2"},
					{imageset = "BaseControl1", image = "SkillInCell3"},
					{imageset = "BaseControl1", image = "SkillInCell4"},
					{imageset = "BaseControl2", image = "SkillInCell5"},
					{imageset = "BaseControl2", image = "SkillInCell6"},
					{imageset = "BaseControl2", image = "SkillInCell7"},
					{imageset = "BaseControl2", image = "SkillInCell8"},
					},

	eBigColors = {"set:MainControl13 image:xiake1",
				"set:MainControl13 image:xiake2",
				"set:MainControl13 image:xiake3",
				"set:MainControl13 image:xiake4",
				"set:MainControl13 image:xiake5",
				"set:MainControl13 image:xiake6",
				"set:MainControl13 image:xiake7",
				"set:MainControl13 image:xiake8",
				},

	eColorDes = {2715, 2716, 2717, 2718, 2719, 2720, 2721, 2722},
	eJieDes = {2768, 2769, 2770},
	eSkillBookType = 2198;
	
	battlePos = {
		1, 1, 1, 1
	},
	practiseLevel = {}
}

--xiake constructor
function makeXiakeItem()
	local xiake = {};
	xiake.onlyid 	= 0;
	xiake.tableid 	= 0;
	xiake.color 	= 0;
	xiake.jie 		= 0;
	xiake.level 	= 0;
	xiake.bornskill = {}; --xiantianskill
	xiake.dynskill  = {}; --houtianskill
	xiake.yuan      = {}; --yuan

	return xiake;
end

--skill constructor
function makeSkillItem()
	local skill = {};
	skill.onlyid 	= 0;
	skill.tableid 	= 0;
	skill.level 	= 0;
	skill.exp 		= 0;

	return skill;
end

--yuan constructor
function makeYuan()
end

--ui util
function XiakeMng.SetWndPos(aWnd, aX, aY)
	aWnd:setPosition(CEGUI.UVector2(
					CEGUI.UDim(0, aX),
					CEGUI.UDim(0, aY)));
end

function XiakeMng.IsBattlePosFull()
	local iCount = 0;
	for i = 1, 4 do
		if XiakeMng.m_vBattleOrder[i] ~= nil and XiakeMng.m_vBattleOrder[i] ~= 0 then
			iCount = iCount + 1;
		end
	end
	
	-- local lvl = GetDataManager():GetMainCharacterLevel();
	-- if lvl >= 28 and lvl < 30 and iCount >= 3 then
	-- 	return true;--addmsg
	-- end

	-- if lvl < 28 and iCount >= 2 then
	-- 	return true;
	-- end
	return false;
end

function XiakeMng.GetSupportXiayiFromXKColorJieci(xkcolor, xkjieci)
    print("_____XiakeMng.GetSupportXiayiFromXKColorJieci")
    
    local ids = std.vector_int_()
    knight.gsp.npc.GetCXiakechangeTableInstance():getAllID(ids)
    local num = ids:size()
    
    print("____xkcolor: " .. xkcolor .. ", xkjieci: " .. xkjieci)
    --print("____num: " .. num)
    for i = 0, num - 1 do
        local record = knight.gsp.npc.GetCXiakechangeTableInstance():getRecorder(ids[i])
        
        --print("____record.color: " .. record.color .. ", record.jieci: " .. record.jieci)
        if record.color == xkcolor and record.jieci == xkjieci then
            return record.xiayi
        end
    end
    
    return 0
end

function XiakeMng.ReadXiakeData(aXiakeID)
	local retXiake = {};	
	local monster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(aXiakeID);
	local shape= knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(monster.modelID);
	retXiake.path = GetIconManager():GetImagePathByID(shape.headID):c_str();
	retXiake.xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(aXiakeID);
    --retXiake.xkxiayi = knight.gsp.npc.GetCXiakeXiaYiTableInstance():getRecorder(aXiakeID);

	return retXiake;
	
--	self.m_pType:setText(xkxx.kinddes);
end

function XiakeMng.cmp(a, b)
	if a ~= nil and b ~= nil then
		if a.color > b.color then return true;
		elseif a.color < b.color then return false;
		elseif a.starlv > b.starlv then return true;
		elseif a.starlv < b.starlv then return false;
		elseif a.xiakeid < b.xiakeid then return true;
		elseif a.xiakeid > b.xiakeid then return false;
		else return a.score > b.score; end
	end
	return false;
end

function XiakeMng.HasSameXKIDInBattleFromXKKey(xkkey, indexNotConsider)
    indexNotConsider = indexNotConsider or -1
    local idCheck = -1
    if XiakeMng.m_vXiakes and XiakeMng.m_vXiakes[xkkey] then
        idCheck = XiakeMng.m_vXiakes[xkkey].xiakeid
    end
    if idCheck <= 0 then
        print("____error no check xiake")
        return false
    end
    for i = 1, 4, 1 do
        if i ~= indexNotConsider then
            local curXK = nil
            if XiakeMng.m_vBattleOrder[i] and XiakeMng.m_vBattleOrder[i] > 0 then
                local keyReg = XiakeMng.m_vBattleOrder[i]
                curXK = XiakeMng.m_vXiakes[keyReg]
            end
            if curXK and curXK.xiakeid > 0 and curXK.xiakeid == idCheck then
                return true
            end
        end
    end
    return false
end

function XiakeMng.HasSameXKIDInBattleFromXKID(xkid, indexNotConsider)
    indexNotConsider = indexNotConsider or -1
    if xkid <= 0 then
        print("____error no check xiake")
        return false
    end
    for i = 1, 4, 1 do
        if i ~= indexNotConsider then
            local curXK = nil
            if XiakeMng.m_vBattleOrder[i] and XiakeMng.m_vBattleOrder[i] > 0 then
                local keyReg = XiakeMng.m_vBattleOrder[i]
                curXK = XiakeMng.m_vXiakes[keyReg]
            end
            if curXK and curXK.xiakeid > 0 and curXK.xiakeid == xkid then
                return true
            end
        end
    end
    return false
end

function XiakeMng.GetXiakesOrderByScore()
	local ret = {};
	for k,v in pairs(XiakeMng.m_vXiakes) do
		if k ~= XiakeMng.m_vBattleOrder[1] and k ~= XiakeMng.m_vBattleOrder[2]
			and k~= XiakeMng.m_vBattleOrder[3] and k ~= XiakeMng.m_vBattleOrder[4] then
		--	ret[k] = v;
		ret[#ret+1] = v;
		end
	end
	table.sort(ret, XiakeMng.cmp);
	return ret;
end

function XiakeMng.GetXiakesOrderByScore_yuanzheng()
	local ret = {}
	local xiakes = {}
	local xiakecount = {}

	-- 找出紫色以上侠客 同类侠客中取最高评分
	for k,v in pairs(XiakeMng.m_vXiakes) do
		-- 紫色以上
		if v.color>3 then
			if not xiakecount[v.xiakeid] then
				xiakecount[v.xiakeid] = v
			else
				local xk = xiakecount[v.xiakeid]
				-- 取评分高的
				if v.score > xk.score then
					-- 如果当前存的非传功侠客
					if not XiakeMng.IsElite(xk.xiakekey) then
						xiakecount[v.xiakeid] = v
					end
				end
			end
		end
	end

	-- 排除已参战侠客
	for i,v in ipairs(XiakeMng.m_vBattleOrder_yuanzheng) do
		local xiake = XiakeMng.GetXiakeFromKey(v)
		xiakecount[xiake.xiakeid] = nil
	end

	for k,v in pairs(xiakecount) do
		table.insert(ret, v)
	end
	-- 按评分排序
	table.sort(ret, XiakeMng.cmp)
	return ret
end

function XiakeMng.cmpColorScoreIncre(a, b)
	if a ~= nil and b ~= nil then
        if a.color < b.color then
            return true
        elseif a.color == b.color then
            return a.score < b.score
        else
            return false
        end
	end
	return false;
end 

function XiakeMng.GetIdleXiakesOrderByColorScoreIncre()
    local ret = {};
	for k,v in pairs(XiakeMng.m_vXiakes) do
		if k ~= XiakeMng.m_vBattleOrder[1] and k ~= XiakeMng.m_vBattleOrder[2]
			and k~= XiakeMng.m_vBattleOrder[3] and k ~= XiakeMng.m_vBattleOrder[4] then
		--	ret[k] = v;
		ret[#ret+1] = v;
		end
	end
	table.sort(ret, XiakeMng.cmpColorScoreIncre);
	return ret;
end

function XiakeMng.GetIdleXiakesOrderByColorScoreIncreExceptGivenKey(keyExcept, removedXKList)
    local ret = {}
    local remove1,remove2,remove3 = -1,-1,-1
    if removedXKList then
        if removedXKList[0] and removedXKList[0] > 0 then
            remove1 = removedXKList[0]
        end
        if removedXKList[1] and removedXKList[1] > 0 then
            remove2 = removedXKList[1]
        end
        if removedXKList[2] and removedXKList[2] > 0 then
            remove3 = removedXKList[2]
        end
    end
	for k,v in pairs(XiakeMng.m_vXiakes) do
		if k ~= XiakeMng.m_vBattleOrder[1] and k ~= XiakeMng.m_vBattleOrder[2] 
            and k ~= XiakeMng.m_vBattleOrder[3] and k ~= XiakeMng.m_vBattleOrder[4] and k ~= keyExcept
            and k ~= remove1 and k ~= remove2 and k ~= remove3 then
                ret[#ret+1] = v
		end
	end
	table.sort(ret, XiakeMng.cmpColorScoreIncre)
	return ret
end

function XiakeMng.RequestXiakeDetail(aXiakeKey)
	local req = knight.gsp.xiake.CGetMyXiakeInfo(aXiakeKey);
	GetNetConnection():send(req);
end

function XiakeMng.RequestUpgradeXiake(aXiakeKey, aMKey)
	local req = knight.gsp.xiake.CUpgradeXiake(aXiakeKey, aMKey);
	GetNetConnection():send(req);
end

function XiakeMng.RequestUpgradeAllXiake(aXiakeKey, aMkeys)
	local req = require "protocoldef.knight.gsp.xiake.cupgradexiakeall".Create()
	req.xiakekey = aXiakeKey
	req.materialkeys = aMkeys
	LuaProtocolManager.getInstance():send(req)
end

function XiakeMng.RequestLearnSkill(aXiakeKey, aBookID)
	local req = knight.gsp.xiake.CLearnSkill(aXiakeKey, aBookID);
	GetNetConnection():send(req);
	print("============Request learn skill==========");
	print(aXiakeKey, aBookID);
end

function XiakeMng.RequestSkillInfo(aXiakeKey, aSkillID)
	local req = knight.gsp.xiake.CViewSkill(aXiakeKey, aSkillID);
	GetNetConnection():send(req);
end

function XiakeMng.RequestSkillUpgrade(aXiakeKey, aSkillID, aBookKeys)
	local req = knight.gsp.xiake.CUpgradeSkill(aXiakeKey, aSkillID, aBookKeys);
	GetNetConnection():send(req);
end

function XiakeMng.RequestChangeSkill(aXiakeKey, aOldSkill, aNewBookKey)
	print("=============request skill change==========");
	local req = knight.gsp.xiake.CChangeSkill(aXiakeKey, aOldSkill, aNewBookKey);
	GetNetConnection():send(req);
end

function XiakeMng.RequestExtSkill(aXiakeKey, aOldSkill, aNewBookKey)
	require "protocoldef.knight.gsp.xiake.cextxiakeskill"
	local p = CExtXiakeSkill.Create()
	p.xiakekey = MyXiake_xiake.getInstance().m_iSelectedXiakeKey
	LuaProtocolManager.getInstance():send(p)
end

---- *protocol process* ----
function XiakeMng.RefreshBattleList(aKey1, aKey2, aKey3, aKey4)
	XiakeMng.m_vBattleOrder[1] = aKey1;
	XiakeMng.m_vBattleOrder[2] = aKey2;
	XiakeMng.m_vBattleOrder[3] = aKey3;
	XiakeMng.m_vBattleOrder[4] = aKey4;
print("battle order:::::", aKey4, aKey3, aKey2, aKey1);
	local bo = BuzhenXiake.peekInstance();
	if bo ~= nil then
		bo:RefreshBattleOrder();
	end

	local myxk = MyXiake_xiake.peekInstance();
	if myxk ~= nil then
		myxk:RefreshMyXiakes();
	end
end

function XiakeMng.AddJiuguanInfo(key, value)
	print("add jiuguan info");
	if XiakeMng.m_vJiuguanInfos == nil then
		XiakeMng.m_vJiuguanInfos = {};
	end
	XiakeMng.m_vJiuguanInfos[key] = value;
	print(tostring(key)..tostring(value).."-------");
end

function XiakeMng.ClearJiuguanInfo()
	print("clear jiuguan info");
	XiakeMng.m_vJiuguanInfos = nil;
end

function XiakeMng.ProcessSOpenXiakeJiuguan(aType, aValue)
	print("process sopenxiakejiuguan:%d,%d", aType, aValue);

  	if aType == 1 then
		XiakeJiuguan.getInstance():Refresh10(aValue);
        if MainControl.getInstanceNotCreate() and MainControl.getInstanceNotCreate().m_i10Time ~= -2 then
			MainControl.getInstanceNotCreate().m_i10Time = aValue
		end
	elseif aType == 2 then
		if aValue == 0 then
			XiakeJiuguan.m_i10Time = -2
			if MainControl.getInstanceNotCreate() then
				MainControl.getInstanceNotCreate().m_i10Time = -2
			end
		end
		XiakeJiuguan.getInstance():Refresh10Left(aValue);
	elseif aType == 3 then
		if MainControl.getInstanceNotCreate() then
			MainControl.getInstanceNotCreate().m_i100Time = aValue
		end
		XiakeJiuguan.getInstance():Refresh100(aValue);
	elseif aType == 4 then
		if MainControl.getInstanceNotCreate() then
			MainControl.getInstanceNotCreate().m_i1000Time = aValue
		end
		XiakeJiuguan.getInstance():Refresh1000(aValue);
	elseif aType == 5 then
		XiakeJiuguan.getInstance():RefreshGotXiake(aValue);
	elseif aType == 6 then
		if XiakeMng.ePriceXiake.x10 ~= aValue then
			XiakeMng.m_b10Chg = true;
		end
		XiakeMng.ePriceXiake.x10 = aValue;
		XiakeJiuguan.getInstance():Refresh10Price(aValue);
	elseif aType == 7 then
		if XiakeMng.ePriceXiake.x100 ~= aValue then
			XiakeMng.m_b100Chg = true;
		end
		XiakeMng.ePriceXiake.x100 = aValue;
		XiakeJiuguan.getInstance():Refresh100Price(aValue);
	elseif aType == 8 then
		if XiakeMng.ePriceXiake.x1000 ~= aValue then
			XiakeMng.m_b1000Chg = true;
		end
		XiakeMng.ePriceXiake.x1000 = aValue;
		XiakeJiuguan.getInstance():Refresh1000Price(aValue);
	end
end

function XiakeMng.RefreshSkillInfo(aXiakeKey, aSkillID, aSkillExp)
	local xiake = XiakeMng.m_vXiakes[aXiakeKey];
	if xiake ~= nil then
		xiake.skills[aSkillID] = aSkillExp;
	end
    local skillQh =	SkillXkQh.peekInstance();
	if skillQh ~= nil and skillQh.m_pMainFrame:isVisible() then
		skillQh:SkillJinhuaResult(aXiakeKey, aSkillID, aSkillExp);
	end
end

function XiakeMng.UpgradeSkillPreview(aXiakeKey, aSkillID, aAddExp)
	local skilljh = SkillXkQh.peekInstance();
	local myxk = MyXiake_xiake.peekInstance();
	if skilljh ~= nil and myxk ~= nil then
		if myxk.m_iSelectedXiakeKey == aXiakeKey then
			skilljh:RefreshPreview(aSkillID, aAddExp);
		end
	end
end

function XiakeMng.ClearMyxiakes()
end

function XiakeMng.GetXiakeFromKey(xkkey)
    --print("____XiakeMng.GetXiakeFromKey")

    if not xkkey then
        return nil
    end
    
    return XiakeMng.m_vXiakes[xkkey]
end

function XiakeMng.RemoveXiakesFromKeyList(keyList)
    LogInfo("____XiakeMng.RemoveXiakesFromKeyList")
    
    for k,v in pairs(keyList) do
        XiakeMng.m_vXiakes[v] = nil
    end
end

function XiakeMng.GetCGPropFromXKKeyAndPropIndex(xkkey, propIndex)
    
    print("____XiakeMng.GetCGPropFromXKKeyAndPropIndex")
    print("____xkkey: " .. xkkey .. " propIndex: " .. propIndex)

    local aXiake = XiakeMng.GetXiakeFromKey(xkkey)
    
    if not aXiake then
        print("____not get xiake")
        return nil
    end
    
    --[[if aXiake.cgprops then
        print("____aXiake.cgprops.xiakekey: " .. aXiake.cgprops.xiakekey)
        print("____aXiake.cgprops.elite: " .. aXiake.cgprops.elite)
        for k,v in pairs(aXiake.cgprops.props) do
            print("____cgprop type: " .. k)
            if v.color and v.star and v.curexp then
                print("____cgprop color: " .. v.color .. " star: " .. v.star .. " curexp: " .. v.curexp)
            else
                print("____error not get color or star or curexp")
            end
        end
    end]]

    local curProp = nil
    if aXiake.bIsDetail and aXiake.cgprops and aXiake.cgprops.elite and aXiake.cgprops.elite == 1 and aXiake.cgprops.props then
        print("____getxiake is elite and aXiake.cgprops.props has exist")
        if propIndex == 1 then
            print("____step1")
            curProp = aXiake.cgprops.props[1]
        elseif propIndex == 2 then
            print("____step2")
            if aXiake.cgprops.props[2] then
                curProp = aXiake.cgprops.props[2]
            else
                curProp = aXiake.cgprops.props[3]
            end
        elseif propIndex >= 3 and propIndex <= 5 then
            print("____step3")
            curProp = aXiake.cgprops.props[propIndex+1]
        end
    end
    
    if curProp then
        print("has prop and the color is: " .. curProp.color .. " star is: " .. curProp.star)
    else
        print("____has not prop")
    end

    return curProp
end

function XiakeMng.IsElite(xkkey)
    local aXiake = XiakeMng.GetXiakeFromKey(xkkey)
    
    if not aXiake then
        return false
    end

    local bElite = false
    if aXiake.bIsDetail and aXiake.cgprops and aXiake.cgprops.elite and aXiake.cgprops.elite == 1 then
        bElite = true
    elseif not aXiake.bIsDetail and aXiake.elite and aXiake.elite == 1 then
        bElite = true
    end
    
    return bElite
end

function XiakeMng.AddXiake(aXiake)
	if aXiake == nil then
		print("receive a nil xiake in SAddxiake");
		return;
	end

	if XiakeMng.m_vXiakes[aXiake.xiakekey] ~= nil then
		--xiake changed
		--if MyXiake_xiake.getInstance() ~= nil and 
		--	MyXiake_xiake.m_pMainFrame:isVisible() ~= false then
		--	MyXiake_xiake.getInstance():RefreshMyXiakes();
		--	end
	end
	XiakeMng.m_vXiakes[aXiake.xiakekey] = aXiake;
	if MyXiake_xiake.peekInstance() ~= nil and 
		MyXiake_xiake.getInstance().m_pMainFrame:isVisible() ~= false then
		MyXiake_xiake.getInstance():RefreshMyXiakes();
	end

	if XiakeJiuguan.peekInstance() ~= nil and XiakeJiuguan.peekInstance().m_iLastXiakeKey ~= 0 then
		XiakeJiuguan.getInstance():RefreshGotXiake(aXiake.xiakekey);
	end
    
    print("____aXiake.xiakekey: " .. aXiake.xiakekey)
    if aXiake.elite then
        print("____aXiake.elite: " .. aXiake.elite)
    end

	-- call on addxiake;
end

function XiakeMng.AddXiakeDetail(aXiakeDetail)
    
    print("____aXiakeDetail.xiakekey: " .. aXiakeDetail.xiakekey)
    if aXiakeDetail.cgprops then
        print("____aXiakeDetail.cgprops.xiakekey: " .. aXiakeDetail.cgprops.xiakekey)
        print("____aXiakeDetail.cgprops.elite: " .. aXiakeDetail.cgprops.elite)
        for k,v in pairs(aXiakeDetail.cgprops.props) do
            print("____cgprop type: " .. k)
            if v.color and v.star and v.curexp then
                print("____cgprop color: " .. v.color .. " star: " .. v.star .. " curexp: " .. v.curexp)
            else
                print("____error not get color or star or curexp")
            end
        end
    end
    

--xiakeid,xiakekey,color,starlv,starlvexp,score,skills,datas
    aXiakeDetail.bIsDetail = true;
	if XiakeMng.m_vXiakes[aXiakeDetail.xiakekey] then
		aXiakeDetail.yuanzheng = XiakeMng.m_vXiakes[aXiakeDetail.xiakekey].yuanzheng or nil
	end
	XiakeMng.m_vXiakes[aXiakeDetail.xiakekey] = aXiakeDetail;

--jinhua use some xiake
	local bHasMxiake = false;
	if XiakeMng.m_MaterialXiakeToBeDelete ~= nil then
		XiakeMng.m_vXiakes[XiakeMng.m_MaterialXiakeToBeDelete.xiakekey] = nil;
		bHasMxiake = true;
	end
--refresh xiake
	local myXiake = MyXiake_xiake.peekInstance();
	if myXiake  ~= nil then
--		myXiake:RefreshCurrentXiake(aXiakeDetail);
		myXiake:RefreshXiakeDetail(aXiakeDetail);
		myXiake.m_iSelectedXiakeKey = aXiakeDetail.xiakekey;
	end

	local jiuguan = XiakeJiuguan.peekInstance();
	if jiuguan ~= nil and jiuguan.m_pMainFrame:isVisible() then
		jiuguan:SetXiakeResult(aXiakeDetail.xiakekey);
	end

	local jinhua = JinhuaXiake.peekInstance();
	if jinhua ~= nil and jinhua.m_pMainFrame:isVisible() and
		jinhua.m_XiakeData.xiakekey == aXiakeDetail.xiakekey then
		if jinhua.m_XiakeData.color ~= aXiakeDetail.color or jinhua.m_XiakeData.starlv ~= aXiakeDetail.starlv then
			if bHasMxiake then
				jinhua:PlayEffectJinhua(true);
			end
		else
			if bHasMxiake then
				jinhua:PlayEffectJinhua(false);
			end
		end
		jinhua.m_XiakeData = aXiakeDetail;
		jinhua:RefreshUpgradePreview(aXiakeDetail.xiakekey, nil);
		jinhua:SetMainXiake(aXiakeDetail);
	end

	if BuzhenXiake:peekInstance() ~= nil then
        BuzhenXiake:peekInstance():RefreshXiakes()
        BuzhenXiake:peekInstance():RefreshBattleOrder()
    end
end

function XiakeMng.UpgradeXiakePreview(aXiakeKey, aAddExp)
	print("added exp"..tostring(aAddExp));
	local jh = JinhuaXiake.peekInstance();
	if jh ~= nil then
		jh:RefreshUpgradePreview(aXiakeKey, aAddExp);
	end
end

function XiakeMng.ExtXiakeSkill(aXiakeKey, aExtSkillNum)
	print("ExtXiakeSkill"..tostring(aXiakeKey));
	XiakeMng.m_vXiakes[aXiakeKey].extskillnum = aExtSkillNum-3;
	local myXiake = MyXiake_xiake.peekInstance();
	if myXiake  ~= nil then
		myXiake:RefreshXiakeDetail(XiakeMng.m_vXiakes[aXiakeKey]);
		myXiake.m_iSelectedXiakeKey = aXiakeKey;
	end
end

function XiakeMng.ProcessJinHua(aJinhuaData)
	print("****jinhua****");
	print(aJinhuaData.xiakekey);
	print(aJinhuaData.xiakeid);
	print(aJinhuaData.color);
	print(aJinhuaData.starlv);
	print(aJinhuaData.starexp);

	for k,v in pairs(aJinhuaData.curdatas) do
		print(tostring(k), "--", tostring(v));
	end

	for k, v in pairs(aJinhuaData.nextdatas) do
		print(tostring(k), "--", tostring(v));
	end
	if JinhuaXiake.peekInstance() ~= nil then
		JinhuaXiake.peekInstance():RefreshJinhuaInfos(aJinhuaData)
	end
end

function XiakeMng.ProcessRefreshXiake(aXiakeData)
--	XiakeMng.m_vXiakes[aXiakeData.xiakekey] = aXiakeData;
--	XiakeMng.AddXiake(aXiakeData);
end

function XiakeMng.OnLevelUp()
	print("on level up");
	for k,v in pairs(XiakeMng.m_vXiakes) do
		v.bIsDetail = false;
	end

    if  GetDataManager():GetMainCharacterLevel() >=60 and not GetScene():IsInFuben() and  not GetBattleManager():IsInBattle() then
		require("ui.zhaohuilaowanjia.daxiazhilubtn").CheckAndShow()
	end
   -- 
    if Config.isKoreanAndroid() and GetDataManager():GetMainCharacterLevel() == 10 then  
       require "luaj"
        luaj.callStaticMethod("com.wanmei.korean.KoreanCommon", "QuDaoPingJia", nil, "()V")
    elseif Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0
       and GetDataManager():GetMainCharacterLevel() == 10
       and Config.CUR_3RD_PLATFORM == "kris" then
        SDXL.ChannelManager:UserFeedBack()
    elseif Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0
       and GetDataManager():GetMainCharacterLevel() == 10
       and Config.CUR_3RD_PLATFORM == "this" then
        SDXL.ChannelManager:UserFeedBack()
    end
    
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lngz" and GetDataManager():GetMainCharacterLevel() == 5 then
        require "luaj"
        luaj.callStaticMethod("com.wanmei.mini.condor.longzhong.PlatformLongZhong", "levleup20", {}, "()V")
    end

end

function KoreanQuDaoPingJiaReward()
	local p = require("protocoldef.knight.gsp.msg.ccommentnotify"):new()
	p.phase = 10
    require("manager.luaprotocolmanager"):send(p)

end

function XiakeMng.RefreshXiaKeYuanZhengData(key, hasdead, qixue)
	local xiake = XiakeMng.GetXiakeFromKey(key)
	if not xiake then
		return
	end
	for k,v in pairs(XiakeMng.m_vXiakes) do
		-- 同类侠客全部修改
		if v.xiakeid == xiake.xiakeid then
			v.yuanzheng = v.yuanzheng or {}
			v.yuanzheng.hasdead = hasdead or v.yuanzheng.hasdead or false
			v.yuanzheng.qixue = qixue or v.yuanzheng.qixue or 1
			if v.yuanzheng.hasdead then
				v.yuanzheng.qixue = 0
			end
		end
	end
end

function XiakeMng.ClearXiaKeYuanZhengData()
	for k,v in pairs(XiakeMng.m_vXiakes) do
		v.yuanzheng = nil
	end
end

function XiakeMng.GetXiaKeYuanZhengData(key)
	local xiake = XiakeMng.GetXiakeFromKey(key)
	if not xiake then
		return nil
	end
	if not xiake.yuanzheng then
		XiakeMng.RefreshXiaKeYuanZhengData(key)
	end
	return xiake.yuanzheng
end

function XiakeMng.run(delta)
	local jiuguan = XiakeJiuguan.peekInstance()
	if XiakeMng.m_i10Time ~= nil and XiakeMng.m_i10Time >= 0 then
		XiakeMng.m_i10Time = XiakeMng.m_i10Time - delta
		if XiakeMng.m_i10Time < 0 then
			XiakeMng.m_i10Time = 0
		end
		if jiuguan ~= nil then
			jiuguan.peekInstance():SetTime(jiuguan.m_pLblTime10, XiakeMng.m_i10Time)
		end
	end
	if XiakeMng.m_i100Time ~= nil and XiakeMng.m_i100Time >= 0 then
		XiakeMng.m_i100Time = XiakeMng.m_i100Time - delta
		if XiakeMng.m_i100Time < 0 then
			XiakeMng.m_i100Time = 0
		end
		if jiuguan ~= nil then
			jiuguan.peekInstance():SetTime(jiuguan.m_pLblTime100, XiakeMng.m_i100Time)
		end
	end
	if XiakeMng.m_i1000Time ~= nil and XiakeMng.m_i1000Time >= 0 then
		XiakeMng.m_i1000Time = XiakeMng.m_i1000Time - delta
		if XiakeMng.m_i1000Time < 0 then
			XiakeMng.m_i1000Time = 0
		end
		if jiuguan ~= nil then
			jiuguan.peekInstance():SetTime(jiuguan.m_pLblTime1000, XiakeMng.m_i1000Time)
		end
	end
end

return XiakeMng;

