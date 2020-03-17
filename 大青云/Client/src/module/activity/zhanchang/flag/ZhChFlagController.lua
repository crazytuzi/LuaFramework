_G.ZhChFlagController = setmetatable({},{__index = IController})
ZhChFlagController.name = "ZhChFlagController";
ZhChFlagController.currFlag = nil;

ZhChFlagController.modelist = {};
ZhChFlagController.timerKey = nil;  -- 计时器

function ZhChFlagController:Create()
	CControlBase:RegControl(self, true) -- 注册鼠标事件吧
	CPlayerControl:AddPickListen(self)
	self.bCanUse = true
	return true
end;

function ZhChFlagController:Update(interval)
	local flaglist = self.modelist;
	if flaglist then 
		for i,mode in pairs(flaglist) do 
			if mode then 
				mode:Update(interval)
			end;
		end;
	end;
	return true;
end;

-- 画旗子最后 indterface
function ZhChFlagController:AddFlag(id,camp)
	local cfg = ZhChFlagConfig[id];
	local id = id;
	local camp = camp;
	local x = cfg.x;
	local y = cfg.y;
	local faceto = cfg.faceto;
	local flag =  ZhChFlag:NewZhChFlag(id,camp)
	if not flag then 
		return 
	end;
	flag:ShowZhChFlag();
	self.modelist[id] = flag;
end;
-- 移除旗子
function ZhChFlagController:DeleteFlag(id)
	local flag = self.modelist[id];
	if not flag then 
		return 
	end;
	if not flag.avatar then 
		return
	end;
	flag.avatar:ExitMap()
	self.modelist[id] = nil;
	flag.avatar = nil
	flag = nil
end;
-- over
function ZhChFlagController:OnRollOver(type, node)
	if type ~= 7 then 
		return 
	end;
	self:OnMouseOver(node)
end
function ZhChFlagController:OnMouseOver(node)

	if node == nil then return; end;
	local id = node.id
	local flag = self.modelist[id]
	-- is my camp
	local cof = ZhanFlagModelConfig[node.camp]
	local zcinfo = ActivityZhanChang.zcInfoVo
	if zcinfo.type ~= cof.camp then 
		return 
	end;
	if flag and flag.type and flag.type == "flag" then
		self:MouseOver(flag)
	end
end
function ZhChFlagController:MouseOver(falg)
	if falg.avatar then
		local light = Light.GetEntityLight(enEntType.eEntType_Flag,CPlayerMap:GetCurMapID());
		falg.avatar:SetHighLight( light.hightlight );
    end
    --CCursorManager:AddState("collect")
    CCursorManager:AddStateOnChar("falg", falg.id)
end;

-- out
function ZhChFlagController:OnRollOut(type, node)
	if type ~= 7 then 
		return 
	end;
	self:OnMouseOut(node)
end
function ZhChFlagController:OnMouseOut(node)
	if node == nil then return; end;
    local id = node.id
    local flag = self.modelist[id]

    -- is my camp
    local cof = ZhanFlagModelConfig[node.camp]
	local zcinfo = ActivityZhanChang.zcInfoVo
	if zcinfo.type ~= cof.camp then 
		return 
	end;


	if flag and flag.type and flag.type == "flag" then
		self:MouseOut(flag)
	end
end
function ZhChFlagController:MouseOut(flag)
	if flag.avatar then 
		flag.avatar:DelHighLight()
    end
    CCursorManager:DelState("falg")

end
-- click 
function ZhChFlagController:OnBtnPick(button, type, node)
	if type ~= 7 then 
		return 
	end;
	ZhChFlagController:OnFlagMouseClick(node)
end

function ZhChFlagController:OnFlagMouseClick(node)

    if node == nil then return; end;
	local id = node.id
    local flag = ZhChFlagConfig[id]--self.modelist[id]
	if not ZhChFlagController:DoCollect(node) then
		local mapid = CPlayerMap:GetCurMapID();
		MainPlayerController:DoAutoRun(mapid,_Vector3.new(flag.x,flag.y,0),function()
			local rst = ZhChFlagController:DoCollect(node)
			if not rst then
				FloatManager:AddNormal(StrConfig['zhanchang113']);
			end
		end);
	end
end

function ZhChFlagController:DoCollect(node)
	if not node then return end;
	local id = node.id;
	self.currFlagID = id;
	local cinfo = ZhChFlagConfig[id];
	local flag = self.modelist[id]
	local myplay = MainPlayerController:GetPos();
	 -- is my camp
   -- local cof = ZhanFlagModelConfig[node.camp]
	local zcinfo = ActivityZhanChang.zcInfoVo
	if zcinfo.type ~= node.camp then 
		--print("弹出，阵营不对")
		return true
	end; 
	if ActivityZhanChang.isHaveFlag ~= nil then
		FloatManager:AddNormal(StrConfig['zhanchang111']);
		return true
	end;
	local dx = myplay.x - cinfo.x;
	local dy = myplay.y - cinfo.y;
	local dist = math.sqrt(dx*dx+dy*dy);
	if dist <= cinfo.r then
		 local cof = ZhanFlagModelConfig[node.camp]
		if flag and flag.type and flag.type == "flag" then
			UIMainColletProgress:Open(cof.name,2000)
			--计时2秒，如果无打断，发消息
			self:IsOpentimer()
			--MountController:RemoveRideMount()
			--CollectionController:SendCollect(flag)
		end
		return true;
	end
	return false;
end

function ZhChFlagController:CloseTimer()
	if not UIMainColletProgress:IsShow() then return end;
	UIMainColletProgress:Hide();
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
end;

function ZhChFlagController:IsOpentimer()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.Ontimer,2000,1);
end;

function ZhChFlagController:Ontimer()
	ZhChFlagController.timerKey = nil;
	ActivityZhanChang:ReqZhanchangFalg(0,ZhChFlagController.currFlagID)
end;

function ZhChFlagController:EscMap()
	for c,a in pairs(self.modelist) do 
		if a then 
		a.avatar:ExitMap()
		end;
	end;
	self.modelist = {};
end;

