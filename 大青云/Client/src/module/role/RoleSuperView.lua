--[[
卓越子面板
2015年11月3日17:27:44
haohu
]]

_G.UIRoleSuper = BaseUI:new("UIRoleSuper")

function UIRoleSuper:Create()
	self:AddSWF("roleEquipSuper.swf", true, nil)
end

function UIRoleSuper:OnLoaded( objSwf )
	objSwf.scrollBar.scroll = function() 
		objSwf.textField._y = 89 + 34 + objSwf.scrollBar.position * -1 * 34
	end;
end

function UIRoleSuper:OnShow()
	self:UpdateShow()
end

function UIRoleSuper:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local text = self:GetStr()
	if text == "" then
		text = StrConfig['role427']
	end
	local tf = objSwf.textField
	tf.htmlText = text
	tf._height = tf.textHeight + 10
	-- objSwf.scrollBar:setScrollProperties( 452, 1, math.floor(tf._height/34) - 12, tf._height )
	local pageSize = math.floor(tf._height/34)
	objSwf.scrollBar:setScrollProperties( pageSize, 1, pageSize - 12, tf._height )
	objSwf.scrollBar.position = 1
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIRoleSuper:ListNotificationInterests()
	return {
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	};
end

--处理消息
function UIRoleSuper:HandleNotification(name, body)
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Role then
			self:UpdateShow()
		end
	end
end

function UIRoleSuper:GetStr()
	local str = ""
	local tab = self:GetSuperTable()
	-- tab = {1,2,3,4,5,6}
	for i, groupId in ipairs(tab) do
		str = str .. self:GetGroupInfo(groupId)
		if i ~= #tab then
			str = str .. self:GetLine()
		end
	end
	return str
end

function UIRoleSuper:GetSuperTable()
	local tab = {}
	local dedupulicate = {}
	local bagVO = BagModel:GetBag( BagConsts.BagType_Role )
	local allEquip = bagVO:GetItemList()
	for _, item in pairs(allEquip) do
		local groupId = EquipModel:GetGroupId(item:GetId())
		if self:IsSuperGroup(groupId) and not dedupulicate[groupId] then
			table.push( tab, groupId )
			dedupulicate[groupId] = true
		end
	end
	table.sort( tab, function( A, B )
		return A < B
	end )
	return tab
end

function UIRoleSuper:IsSuperGroup(groupId)
	local _, groupMap = self:GetGroupList()
	return groupMap[groupId] == true
end

local groupList, groupMap
function UIRoleSuper:GetGroupList()
	if not groupList or not groupMap then
		local str = t_consts[139].param
		local tab = split(str, "#")
		groupList = {}
		groupMap = {}
		for _, v in ipairs(tab) do
			local groupId = tonumber(v)
			table.push( groupList, groupId )
			groupMap[groupId] = true
		end
	end
	return groupList, groupMap
end

--套装信息
function UIRoleSuper:GetGroupInfo(groupId)
	local str = "";
	if groupId == 0 then
		return str;
	end
	local groupCfg = t_equipgroup[groupId];
	if not groupCfg then return str; end
	local totalNum = 11;--套装总数量
	local num = 0;--拥有套装数量
	--
	local hasEquipList = {};

	local bagVO = BagModel:GetBag( BagConsts.BagType_Role )
	local allEquip = bagVO:GetItemList()
	for _, item in pairs(allEquip) do
		if EquipModel:GetGroupId( item:GetId() ) == groupId then
			num = num + 1;
			local equipCfg = t_equip[item:GetTid()];
			if equipCfg then
				hasEquipList[equipCfg.pos] = true;
			end
		end
	end
	-- trace(hasEquipList)
	--
	str = str .. self:GetHtmlText(string.format("%s（%s/%s）",groupCfg.name,num,totalNum),"#00ff00",nil);
	str = str .. self:GetVGap(20);
	local startPos = BagConsts.Equip_WuQi;
	local endPos = BagConsts.Equip_JieZhi2;
	for i=startPos,endPos,1 do
		if hasEquipList[i] then
			str = str .. self:GetHtmlText(BagConsts:GetEquipName(i),"#00ff00",nil,false);
		else
			str = str .. self:GetHtmlText(BagConsts:GetEquipName(i),"#5a5a5a",nil,false);
		end
		str = str .. "    ";
	end
	str = str .. "<br/>";
	str = str .. self:GetVGap(20);
	for i=2,11 do
		local attrCfg = groupCfg["attr"..i];
		if attrCfg ~= "" then
			str = str .. self:GetHtmlText(string.format( StrConfig['role428'], i ),"#fd9620",nil,true);
			local attrStr = "";
			local attrlist = AttrParseUtil:Parse(attrCfg);
			for i=1,#attrlist do
				local leftmargin = i * 105
				-- local leading = (i == #attrlist) and 10 or -32
				local leading = -32
				attrStr = attrStr .. string.format( "<textformat leading='%s' leftmargin='%s'><p>%s  +%s</p></textformat>",leading,
					leftmargin,	enAttrTypeName[attrlist[i].type], getAtrrShowVal(attrlist[i].type,attrlist[i].val) )
			end
			if num >= i then
				attrStr = self:GetHtmlText(attrStr,"#00ff00",nil,true);
			else
				attrStr = self:GetHtmlText(attrStr,"#5a5a5a",nil,true);
			end
			str = str.. "<textformat leading='36'><p>" ..attrStr .. "</p></textformat><br/>";
			-- str = str .. attrStr;
		end
	end
	return str;
end

--获取一个竖向的间隙
function UIRoleSuper:GetVGap(gap)
	return "<p><img height='" .. gap .. "' align='baseline' vspace='0'/></p>";
end

--获取Html文本
--@param text 显示的内容
--@param color 字体颜色
--@param size 字号
--@param withBr 是否换行,默认true
--@param bold 	是否加粗,默认false
function UIRoleSuper:GetHtmlText(text,color,size,withBr,bold)
	if not color then color = TipsConsts.Default_Color; end
	if not size then size = 16; end
	if withBr==nil then withBr = true; end
	if bold==nil then bold = false; end
	local str = "<font color='" .. color .."' size='" .. size .. "'>";
	if bold then
		str = str .. "<b>" .. text .. "</b>";
	else
		str = str .. text;
	end
	str = str .. "</font>";
	if withBr then
		str = str .. "<br/>";
	end
	return str;
end

--获取一条线
--@param topGap 线的上间距,默认10
--@param bottomGap 线的下间距,默认取上间距
function UIRoleSuper:GetLine(topGap,bottomGap)
	if not topGap then topGap = 10; end
	if not bottomGap then bottomGap = topGap; end
	return "<p><img height='".. topGap .."'/></p><p><img width='".. self:GetWidth()-30 .."' height='1' align='baseline' vspace='".. bottomGap .."' src='" .. ResUtil:GetTipsLineUrl() .."'/></br></p>"
end