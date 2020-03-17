--[[
帮派仓库操作信息
wangshuau
]]

_G.UIUnionWareHouseInfomation = BaseUI:new("UIUnionWareHouseInfomation")

UIUnionWareHouseInfomation.curShowType = 0;
function UIUnionWareHouseInfomation:Create()
	self:AddSWF("unionWareInfomation.swf",nil,true)
end;

function UIUnionWareHouseInfomation:OnLoaded(objSwf)
	-- test 
	--self:TestInfo();
	objSwf.allBtn.click = function() self:AllBtnRulesShow() end;
	objSwf.overBtn.click = function() self:OverBtnRulesShow() end;
	objSwf.outBtn.click = function() self:OutBtnRulesShow() end;
	objSwf.decombtn.click = function() self:OutBtnDecomShow() end;
end;

function UIUnionWareHouseInfomation:OnShow()
	UnionController:ReqWareHouseOperInfo() -- 请求协议
	local objSwf = self.objSwf;
	self.curShowType = 0;
	objSwf.allBtn.selected = true;
	--self:ShowInfoList();
end;
function UIUnionWareHouseInfomation:OnHide()

end;
 --全部
function UIUnionWareHouseInfomation:AllBtnRulesShow()
	self.curShowType = 0;
	self:ShowInfoList();
end;
 -- 存入
function UIUnionWareHouseInfomation:OverBtnRulesShow()
	self.curShowType = 1;
	self:ShowInfoList();
end;
 -- 取出
function UIUnionWareHouseInfomation:OutBtnRulesShow()
	self.curShowType = 2;
	self:ShowInfoList();
end;

-- 熔炼
function UIUnionWareHouseInfomation:OutBtnDecomShow()
	self.curShowType = 3;
	self:ShowInfoList();
end;

function UIUnionWareHouseInfomation:ShowInfoList()
	local objSwf = self.objSwf;
	local list = UnionModel:GetWareInfomation()
	local listvo = {};
	for i,info in ipairs(list) do 
		local vo ={};
		vo.txt = self:GetText(info);
		if vo.txt then 
			if self.curShowType == 0 then 
				table.push(listvo,UIData.encode(vo))
			end;
			if self.curShowType == 1 then 
				if info.opertype == self.curShowType then 
					table.push(listvo,UIData.encode(vo))
				end;
			end;
			if self.curShowType == 2 then 
				if info.opertype == self.curShowType then 
					table.push(listvo,UIData.encode(vo))
				end;
			end;
			if self.curShowType == 3 then 
				if info.opertype == self.curShowType then 
					table.push(listvo,UIData.encode(vo))
				end;
			end;
		end;	
	end;
	objSwf.infolist.dataProvider:cleanUp();
	objSwf.infolist.dataProvider:push(unpack(listvo));
	objSwf.infolist:invalidateData();
	objSwf.scrollbar.position = 0;
end;

function UIUnionWareHouseInfomation:GetText(info)
	local vo = {};
	local year, month, day, hour, minute, second = CTimeFormat:todate(info.time,true);
	local time = string.format(StrConfig["unionwareHouse502"],year,month,day,hour,minute,second)
	local equipname = ""
	local nameColor = ""
	if t_equip[info.itemid] then 
		equipname = t_equip[info.itemid].name
		nameColor = TipsConsts:GetItemQualityColor(t_equip[info.itemid].quality)
	elseif t_item[info.itemid] then 
		equipname = t_item[info.itemid].name
		nameColor = TipsConsts:GetItemQualityColor(t_item[info.itemid].quality)
	end;
	
	if info.opertype == 1 then -- 存入
		vo.txt = string.format(StrConfig["unionwareHouse500"],time,info.roleName,nameColor,equipname,info.num,info.cont)
	elseif info.opertype == 2 then  -- 取出
		vo.txt = string.format(StrConfig["unionwareHouse501"],time,info.roleName,nameColor,equipname,info.num,info.cont)
	elseif info.opertype == 3 then  -- 取出
		vo.txt = string.format(StrConfig["unionwareHouse506"],time,nameColor,equipname,info.num,info.cont)
	end;
	return vo.txt
end;


function UIUnionWareHouseInfomation:TestInfo()
	local list = {};
	for i=1,50 do 
		local vo = {};
		vo.time = 99990000+(math.random(2000)*i);
		vo.roleName = "拖尼玛"..i;
		vo.opertype = math.random(2);
		vo.itemid = 220903000+math.random(10);
		vo.num = math.random(10);
		vo.cont = math.random(1000)
		table.push(list,vo)
	end;
	UnionModel:SetUnionInfomation(list) 
end;

--------------------------Notification
function UIUnionWareHouseInfomation:ListNotificationInterests()
	return {
			NotifyConsts.UnionWareHouseOperInfo,
			};
end
function UIUnionWareHouseInfomation:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.UnionWareHouseOperInfo then 
		self:ShowInfoList();
	end;
end;


