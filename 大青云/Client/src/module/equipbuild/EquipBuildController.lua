--[[
装备打造
wangshuai
]]
_G.EquipBuildController = setmetatable({},{__index=IController})
EquipBuildController.name = "EquipBuildController";

function EquipBuildController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_EquipBuildOpenList,self,self.SetOpenlist); -- 8383
	MsgManager:RegisterCallBack(MsgType.SC_EquipBuildStart,self,self.SetBuildResult); -- 8384

	-- 装备粉碎
	MsgManager:RegisterCallBack(MsgType.SC_EquipDecompose,self,self.EquipDecompResult); -- 8388
end;

function EquipBuildController:OnEnterGame()
	self:InitInfo()
	--self:Falsedata();
end;	

function EquipBuildController:Falsedata()
	local list = {};
	for i=1,10 do 
		local vo = {}
		vo.id = i;
		table.push(list,vo)
	end;
	local msg = {};
	msg.openlist = list;
	self:SetOpenlist(msg)
end;
-- 开启列表，
function EquipBuildController:SetOpenlist(msg)
	for i,info in ipairs(msg.openlist) do 
		EquipBuildModel:SetBuildInfo(info.id,true)
	end;
	-- print("收到开启列表")
	-- trace(msg)
	Notifier:sendNotification(NotifyConsts.EquipBuildOpenList);
end;

-- 打造结果
function EquipBuildController:SetBuildResult(msg)
	--trace(msg)
	 --新卓越属性，特殊处理
    for i,ao in ipairs(msg.list) do 
        for p,vo in  ipairs(ao.newSuperList) do 
            if vo.id > 0  and vo.wash == 0 then 
                local cfg = t_zhuoyueshuxing[vo.id];
                vo.wash = cfg and cfg.val or 0;
            end;    
        end;
    end;
    --
	
	if msg.result == 0 then 
		EquipBuildModel:SetResultData(msg.list)
		Notifier:sendNotification(NotifyConsts.EquipBuildResultUpdata);
		SoundManager:PlaySfx(2043);
	end;
end;

-- 初始化信息
function EquipBuildController:InitInfo()
	local list = {};
	local lvl = MainPlayerModel.humanDetailInfo.eaLevel
	for i,info in ipairs(t_equipcreate) do
		local vo = {};	
		vo.id = info.id;
		vo.cid = info.cid
		if info.unlock <= lvl then 
			vo.isOpen = true;
		else
			vo.isOpen = false;
		end;
		if not list[info.order] then list[info.order] = {} end;
		-- table.push(list[info.order],vo)
		list[info.order][info.indexc] = vo;
	end;
	EquipBuildModel:SetInitInfo(list)
end;


function EquipBuildController:SendDazaoA(id,isvip,num,buildType)
	
	local bo,erType = EquipBuildUtil:GetIsCanBuy(id,isvip,buildType)
	if bo == false then 
		if erType == 1 then --不是vip
			FloatManager:AddNormal(StrConfig["equipbuild007"],UIEquipBuild:GetBuildBtn());
		elseif erType == 2 then -- 金币不足
			FloatManager:AddNormal(StrConfig["equipbuild008"],UIEquipBuild:GetBuildBtn());
		elseif erType == 3 then --活力值不足
			FloatManager:AddNormal(StrConfig["equipbuild009"],UIEquipBuild:GetBuildBtn());
		elseif erType == 4 then -- 材料不足
			FloatManager:AddNormal(StrConfig["equipbuild010"],UIEquipBuild:GetBuildBtn());
		end;
		return 
	end;
	-- if not EquipBuildUtil:GetIsCanBuy(id,isvip) then 
		
	-- 	return 
	-- end;

	local msg = ReqEquipBuildStartMsg:new();
	msg.id = id;
	msg.isVip = isvip;
	msg.num = num;
	msg.buildType = buildType;
	MsgManager:Send(msg)
	-- trace(msg)
	-- print("请求装备打造")
end;

---------------------装备粉碎

function EquipBuildController:EquipDecompResult(msg)
	--trace(msg)
	if msg.result == 0 then 
		local list = {};
		for i,info in ipairs(msg.chiplist) do 
			if list[info.cid] then 
				list[info.cid].num = list[info.cid].num + info.num;
			else
				local vo ={};
				vo.id = info.cid;
				vo.num = info.num;
				list[info.cid] = vo;
			end;
		end;
		Notifier:sendNotification(NotifyConsts.EquipDecompResult);
	else
		-- 失败
	end;
end;

function EquipBuildController:ReqDecompEquip(list)
	local msg = ReqEquipDecomposeMsg:new();
	msg.equiplist = list;
	MsgManager:Send(msg)
	--trace(msg)
end;