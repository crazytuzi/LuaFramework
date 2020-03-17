_G.DiGongFlagController = setmetatable({},{__index = IController})
DiGongFlagController.name = "DiGongFlagController";
DiGongFlagController.currFlag = nil;

DiGongFlagController.modelist = {};
DiGongFlagController.timerKey = nil;  -- 计时器

function DiGongFlagController:Create()
	CControlBase:RegControl(self, true) -- 注册鼠标事件吧
	CPlayerControl:AddPickListen(self)
	self.bCanUse = true
	return true
end;

function DiGongFlagController:Update(interval)
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
function DiGongFlagController:AddFlag(cfg)
	local flag =  DiGongFlag:NewDiGongFlag(cfg);
	if not flag then 
		return 
	end;
	flag:ShowDiGongFlag();
	self.modelist[1] = flag;
end;
-- 移除旗子
function DiGongFlagController:DeleteFlag()
	local flag = self.modelist[1];
	if not flag then 
		return 
	end;
	if not flag.avatar then 
		return
	end;
	flag.avatar:ExitMap()
	self.modelist[1] = nil;
	flag.avatar = nil
	flag = nil
end;
-- over
function DiGongFlagController:OnRollOver(type, node)
	if type ~= enEntType.eEntType_DigongFlag then 
		return 
	end;
	self:OnMouseOver(node)
end
function DiGongFlagController:OnMouseOver(node)

	if node == nil then return; end;
	local id = node.id
	local flag = self.modelist[1]
	if flag and flag.type and flag.type == "digongflag" then
		self:MouseOver(flag)
	end
end
function DiGongFlagController:MouseOver(falg)

	if falg.avatar then
		local light = Light.GetEntityLight(enEntType.eEntType_DigongFlag,CPlayerMap:GetCurMapID());
		falg.avatar:SetHighLight( light.hightlight )
    end
    --CCursorManager:AddState("collect")
    CCursorManager:AddStateOnChar("digongflag", falg.id)
end;

-- out
function DiGongFlagController:OnRollOut(type, node)
	if type ~= enEntType.eEntType_DigongFlag then 
		return 
	end;
	self:OnMouseOut(node)
end
function DiGongFlagController:OnMouseOut(node)
	if node == nil then return; end;
    local id = node.id
    local flag = self.modelist[1]

	if flag and flag.type and flag.type == "digongflag" then
		self:MouseOut(flag)
	end
end
function DiGongFlagController:MouseOut(flag)
	if flag.avatar then 
		flag.avatar:DelHighLight()
    end
    CCursorManager:DelState("digongflag")

end
-- click 
function DiGongFlagController:OnBtnPick(button, type, node)
	if type ~= enEntType.eEntType_DigongFlag then 
		return 
	end;
	DiGongFlagController:OnFlagMouseClick(node)
end

function DiGongFlagController:OnFlagMouseClick(node)

    if node == nil then return; end;
	if not DiGongFlagController:DoCollect() then
		local mapid = CPlayerMap:GetCurMapID();
		local flagx,flagy = UnionDiGongModel:GetFlagPos();
		MainPlayerController:DoAutoRun(mapid,_Vector3.new(flagx,flagy,0),function()
			local rst = DiGongFlagController:DoCollect()
			if not rst then
				FloatManager:AddNormal(StrConfig['zhanchang113']);
			end
		end);
	end
end

function DiGongFlagController:DoCollect()
	local flag = self.modelist[1]
	local myplay = MainPlayerController:GetPos();
	local cinfox,cinfoy = UnionDiGongModel:GetFlagPos();
	local dx = myplay.x - cinfox;
	local dy = myplay.y - cinfoy;
	local dist = math.sqrt(dx*dx+dy*dy);
	if dist <= 20 then
		if flag and flag.type and flag.type == "digongflag" then
			UIMainColletProgress:Open("域外邪族战旗",2000)
			--计时2秒，如果无打断，发消息
			self:IsOpentimer()
			--MountController:RemoveRideMount()
			--CollectionController:SendCollect(flag)
		end
		return true;
	end
	return false;
end

function DiGongFlagController:CloseTimer()
	if not UIMainColletProgress:IsShow() then return end;
	UIMainColletProgress:Hide();
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
end;

function DiGongFlagController:IsOpentimer()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.Ontimer,2000,1);
end;

function DiGongFlagController:Ontimer()
	DiGongFlagController.timerKey = nil;
	UnionDiGongController:ReqUnionDiGongPickFlag();
end;

function DiGongFlagController:EscMap()
	for c,a in pairs(self.modelist) do 
		if a then 
		a.avatar:ExitMap()
		end;
	end;
	self.modelist = {};
end;

