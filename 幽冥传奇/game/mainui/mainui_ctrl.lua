require("scripts/game/mainui/mainui_view")
require("scripts/game/mainui/mainui_data")

-- 主界面
MainuiCtrl = MainuiCtrl or BaseClass(BaseController)

function MainuiCtrl:__init()
	if MainuiCtrl.Instance then
		ErrorLog("[MainuiCtrl]:Attempt to create singleton twice!")
	end
	MainuiCtrl.Instance = self

	self.data = MainuiData.New()
	self.view = MainuiView.New(ViewDef.MainUi)

	self:RegisterAllEvents()
end

function MainuiCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	MainuiCtrl.Instance = nil
end

function MainuiCtrl:RegisterAllEvents()
end

function MainuiCtrl:OpenHorn(msg)
	self.view:GetChat():OpenHorn(msg)
end

function MainuiCtrl:GetView()
	return self.view
end

function MainuiCtrl:GetRootLayout()
	return self.view:GetRootLayout()
end

function MainuiCtrl:Open()
	self.view:Open()
end

-- 主界面任务栏是否显示中
function MainuiCtrl:IsMainTaskVis()
	local task_bar = self.view:GetTask()
	if task_bar then
		return task_bar:GetMtLayoutVis()
	end
end

--  按类型添加或删除提示图标
function MainuiCtrl:InvateTip(type, repetition_num, callback, param)
	if nil == self.view:GetSmallTip() then
		return
	end
	if IS_ON_CROSSSERVER then
		if not (type == MAINUI_TIP_TYPE.TEAM
			or type == MAINUI_TIP_TYPE.FREE_CROSSBRAND) then
			return
		end
	end

	if repetition_num > 0 then
		return self.view:GetSmallTip():AddTipIcon(type, callback, repetition_num, param)
	else
		return self.view:GetSmallTip():RemoveTipIcon(type)
	end
end

function MainuiCtrl:GetTipIcon(type)
	return self.view:GetSmallTip():GetTipIcon(type)
end

function MainuiCtrl:GetTaskGuideName(guide_type)
end
function MainuiCtrl:SetHeadAndRightTopVisible(vis)
	self.view:SetHeadAndRightTopVisible(vis)
end


function MainuiCtrl:ShowTipText(p_index)
	self.view:ShowTip(p_index)
end

function MainuiCtrl:SetRemoveEffect(view_def)
	self.view:SetRemoveCharge(view_def)
end


function MainuiCtrl:OpenBaseViewRenderTexture()
	if not self.render then
		self.view:SetVisible(false)
		-- local size = cc.Director:getInstance():getWinSize()
		-- self.render = cc.RenderTexture:create(size.width, size.height,cc.TEXTURE2_D_PIXEL_FORMAT_RG_B888)
		-- self.render:beginWithClear(0,0,0,0)
		-- AdapterToLua:GetGameScene():getRenderGroup(GRQ_TERRAIN):visit()
		-- AdapterToLua:GetGameScene():getRenderGroup(GRQ_SCENE_OBJ):visit()
		-- self.render:endToLua()
		-- self.render:setPosition(size.width/2,size.height/2)
		-- HandleRenderUnit:AddUi(self.render, 0, 0)
		-- AdapterToLua:GetGameScene():getRenderGroup(GRQ_TERRAIN):setVisible(false)
		-- AdapterToLua:GetGameScene():getRenderGroup(GRQ_SCENE_OBJ):setVisible(false)
		self.render = {}
		self.render.times = 1
	else
		self.render.times = self.render.times + 1
	end
end

function MainuiCtrl:CloseBaseViewRenderTexture()
	if self.render then
		self.render.times = self.render.times - 1
		if self.render.times <= 0 then
			self.view:SetVisible(true)
			-- AdapterToLua:GetGameScene():getRenderGroup(GRQ_TERRAIN):setVisible(true)
			-- AdapterToLua:GetGameScene():getRenderGroup(GRQ_SCENE_OBJ):setVisible(true)
			-- self.render:removeFromParent()
			self.render = nil
		end
	end
end