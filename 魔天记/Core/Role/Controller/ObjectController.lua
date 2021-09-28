require "Core.Role.Controller.AbsController";
require "Core.Role.ModelCreater.ObjectModelCreater"

ObjectController = class("ObjectController", AbsController);

ObjectController.Status = {
	Stand = 1,
	Finish = 2,
	Hide = 3
}

function ObjectController:ctor(info)
	self:_Init(info);
end

function ObjectController:_Init(data)
	self.id = data.id;
	self.info = data;
	self:_InitEntity(EntityNamePrefix.OBJ .. self.id);
    self:SetLayer(Layer.NPC);
    self:_LoadModel(ObjectModelCreater);

    local pos = Convert.PointFromServer(self.info.x, self.info.y, self.info.z);
    self:SetPosition(pos, self.info.angle)

    self:Start();
end

function ObjectController:Start()

	if self.info.effect ~= "" then
		self.effect1 = Resourcer.Get("Effect/ScenceEffect", self.info.effect, self.transform);
	end
	if self.effect1 then
		self.effect1:SetActive(false);
	end

	if self.info.effect2 ~= "" then
		self.effect2 = Resourcer.Get("Effect/ScenceEffect", self.info.effect2, self.transform);
	end
	if self.effect2 then
		self.effect2:SetActive(false);
	end

	if self.info.type > 0 then
		self:SetEnable(false);
	else
		self._enable = true;
	end
	self:Stand();
end

function ObjectController:Stand()
	self:Play("sleep");
	self.status = ObjectController.Status.Stand;
end

function ObjectController:Finish()
	self:Play("wake");
	if self.effect2 then
		self.effect2:SetActive(true);
	end
	self.status = ObjectController.Status.Finish;
	if self._timer then
        self._timer:Reset( function(val) self:Hide(val) end, 2, 1, false);
        if self._timer.running == false then
        	self._timer:Start();
        end
    else
        self._timer = Timer.New( function(val) self:Hide(val) end, 2, 1, false);
        self._timer:Start();
    end

    --如果需要刷新.
    if self.info.refresh_time > 0 then
    	--提前设置隐藏.
    	self._isHide = true;
    end
    
end

function ObjectController:Hide(val)
	if self.effect2 then
		self.effect2:SetActive(false);
	end
	--设置刷新
	local time = self.info.refresh_time or 0;
	if time > 0 then
		self._isHide = true;
		self:SetEnable(false);
		if self._resetTimer then
	        self._resetTimer:Reset( function() self:Reset() end, time / 1000, 1, false);
	        if self._resetTimer.running == false then
        		self._resetTimer:Start();
        	end
	    else
	        self._resetTimer = Timer.New( function() self:Reset() end, time / 1000, 1, false);
	        self._resetTimer:Start();
	    end
	end
end

function ObjectController:Play(name, returnActionTime)
	if (self._roleCreater) then
        self._roleCreater:Play(name, returnActionTime)
    end
end

function ObjectController:Reset()
	self:Stand();
	self:SetEnable(true);
	self._isHide = false;
end

function ObjectController:UpdateByTask()
	local taskId = self.info.taskId;
	local task = TaskManager.GetTaskById(taskId)
	local showByTask = task and task.status == TaskConst.Status.IMPLEMENTATION;

	if self.info.type == 0 or showByTask then
		--显示的时候 如果是非活动, 非隐藏状态, 则置为活动
		if not self._enable and not self._isHide then
			self:SetEnable(true);
		end
	else
		if self._enable then
			self:SetEnable(false);
		end
	end

	if showByTask then 
		if self.effect1 and self.effect1.activeSelf == false then
			self.effect1:SetActive(true);
		end
	else
		if self.effect1 and self.effect1.activeSelf == true then
			self.effect1:SetActive(false);
		end
	end
end

function ObjectController:SetEnable(v)
	self._enable = v;
    self:SetVisible(v)
	--self.gameObject:SetActive(v);
end

function ObjectController:IsEnable()
	return self._enable and not self._isHide;
end

function ObjectController:_DisposeHandler()

	if self._timer then 
        self._timer:Stop()
        self._timer = nil
    end

    if self._resetTimer then 
        self._resetTimer:Stop()
        self._resetTimer = nil
    end

    if self.effect1 then
    	Resourcer.Recycle(self.effect1)
    end

    if self.effect2 then
		Resourcer.Recycle(self.effect2)
	end

end


function ObjectController:IsDie()
	return true;
end
