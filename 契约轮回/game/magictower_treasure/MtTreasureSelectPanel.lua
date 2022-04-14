--
-- @Author: LaoY
-- @Date:   2018-12-20 19:36:57
--
MtTreasureSelectPanel = MtTreasureSelectPanel or class("MtTreasureSelectPanel",BasePanel)
local MtTreasureSelectPanel = MtTreasureSelectPanel

function MtTreasureSelectPanel:ctor()
	self.abName = "magictower_treasure"
	self.assetName = "MtTreasureSelectPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.panel_type = 1

	self.model = MagictowerTreasureModel:GetInstance()
end

function MtTreasureSelectPanel:dctor()
	self:StopTime()

	if self.model_event_list then
		self.model:RemoveTabListener(self.model_event_list)
		self.model_event_list = {}
	end
end

function MtTreasureSelectPanel:Open( )
	MtTreasureSelectPanel.super.Open(self)
end

function MtTreasureSelectPanel:LoadCallBack()
	self.nodes = {
		"text_time","img_magic_monster_2","img_magic_monster_1","img_magic_monster_4","btn_close","text_des","img_magic_monster_3","btn_go"
	}
	self:GetChildren(self.nodes)

	self.text_des_component = self.text_des:GetComponent('Text')
	self.text_des_component.text = MtTreasureConstant.SelectDes

	self.text_time_component = self.text_time:GetComponent('Text')

	SetAlignType(self.btn_close,bit.bor(AlignType.Right,AlignType.Null))

	self:AddEvent()
end

function MtTreasureSelectPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btn_close.gameObject,call_back)

	local function call_back(target,x,y)
		-- Notify.ShowText(1)
		if self.model:FindIndex(1) then
			self:Close()
		end
	end
	AddClickEvent(self.img_magic_monster_1.gameObject,call_back)

	local function call_back(target,x,y)
		-- Notify.ShowText(2)
		if self.model:FindIndex(2) then
			self:Close()
		end
	end
	AddClickEvent(self.img_magic_monster_2.gameObject,call_back)

	local function call_back(target,x,y)
		-- Notify.ShowText(3)
		if self.model:FindIndex(3) then
			self:Close()
		end
	end
	AddClickEvent(self.img_magic_monster_3.gameObject,call_back)

	local function call_back(target,x,y)
		-- Notify.ShowText(4)
		if self.model:FindIndex(4) then
			self:Close()
		end
	end
	AddClickEvent(self.img_magic_monster_4.gameObject,call_back)

	local function call_back(target,x,y)
		local scene_id = SceneManager:GetInstance():GetSceneId()
		if self.model.mt_treasure_info.scene == scene_id then
			Notify.ShowText("You are already hunting treasures, please select a fairy")
			return
		end
		local function call_back1()
			-- SceneControler:GetInstance():RequestSceneChange(self.model.mt_treasure_info.scene, 2)
			-- SceneControler:GetInstance():RequestSceneLeave(true)
			self.model:EnterMttScene()
		end
		self.model:CheckEnterNpcScene(call_back1)
	end
	AddClickEvent(self.btn_go.gameObject,call_back)

	self.model_event_list = {}
	local function time_out_func()
		Dialog.ShowOne("Tip","Event timed out, please restart","Confirm",handler(self,self.Close),10)
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.TimeOut,time_out_func)
end

function MtTreasureSelectPanel:OpenCallBack()
	self:UpdateView()
	self:StartTime()
end

function MtTreasureSelectPanel:UpdateView( )
	local scene_id = SceneManager:GetInstance():GetSceneId()
	-- SetVisible(self.btn_go,self.model.mt_treasure_info.scene ~= scene_id)
end

function MtTreasureSelectPanel:StartTime()
	self:StopTime()
	local end_time = self.model.mt_treasure_info.etime
	local function step()
		local cur_time = os.time()
		if end_time - cur_time >= 0 then
			local data = TimeManager:GetLastTimeData(cur_time,end_time)
			if data then
				local str = string.format("%02d：%02d",data.min or 0,data.sec)
				self.text_time_component.text = str
			end
		else
			self:StopTime()
			-- self:Close()
		end
	end
	self.time_id = GlobalSchedule:Start(step,1.0)
	step()
end

function MtTreasureSelectPanel:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = nil
	end
end

function MtTreasureSelectPanel:CloseCallBack(  )

end