
require("game/funfuben/eqxpresion_fu_ben_data")
require("game/funfuben/fun_open_victory_view")
require("game/funfuben/mount_fu_ben_view")
require("game/funfuben/wing_fu_ben_view")
require("game/funfuben/jingling_fu_ben_view")

ExpresionFuBenCtrl = ExpresionFuBenCtrl or BaseClass(BaseController)

function ExpresionFuBenCtrl:__init()
	if ExpresionFuBenCtrl.Instance ~= nil then
		print_error("[ExpresionFuBenCtrl] Attemp to create a singleton twice !")
		return
	end
	ExpresionFuBenCtrl.Instance = self
	self.expresion_fu_ben_data 	= ExpresionFuBenData.New()
	-- self.mount_fu_ben_view 		= MountFuBenView.New(ViewName.MountFuBenView) --坐骑副本
	-- self.wing_fu_ben_view 		= WingFuBenView.New(ViewName.WingFuBenView)	--羽翼副本
	-- self.jingling_fu_ben_view 	= JingLingFuBenView.New(ViewName.JingLingFuBenView)--精灵副本

	-- self.fun_open_victory_view = FunOpenVictoryView.New(ViewName.FunOpenVictoryView)

	self:RegisterAllProtocols()
end

function ExpresionFuBenCtrl:__delete()
	self.expresion_fu_ben_data:DeleteMe()
	ExpresionFuBenCtrl.Instance = nil

	-- self.mount_fu_ben_view:DeleteMe()
	-- self.mount_fu_ben_view = nil

	-- self.wing_fu_ben_view:DeleteMe()
	-- self.wing_fu_ben_view = nil

	-- self.jingling_fu_ben_view:DeleteMe()
	-- self.jingling_fu_ben_view = nil

	-- self.fun_open_victory_view:DeleteMe()
	-- self.fun_open_victory_view = nil
end

function ExpresionFuBenCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCFunOpenMountInfo, "GetFunOpenMountInfo")
	-- self:RegisterProtocol(SCFunOpenWingInfo, "GetWingFuBenInfo")
	-- self:RegisterProtocol(SCFunOpenJinglingInfo, "GetJingLingFuBenInfo")
end

-- 坐骑副本信息返回
function ExpresionFuBenCtrl:GetFunOpenMountInfo(protocol)
	self.expresion_fu_ben_data:SetMountFuBenInfo(protocol)

	-- if ViewManager.Instance:IsOpen(ViewName.MountFuBenView) then
	-- 	self.mount_fu_ben_view:Flush()
	-- end
	-- if protocol.is_finish == 1 then
	-- 	ViewManager.Instance:Open(ViewName.FunOpenVictoryView)
	-- end
end

-- 羽翼副本信息返回
function ExpresionFuBenCtrl:GetWingFuBenInfo(protocol)
	self.expresion_fu_ben_data:SetWingFuBenInfo(protocol)
	-- if ViewManager.Instance:IsOpen(ViewName.WingFuBenView) then
	-- 	self.wing_fu_ben_view:Flush()
	-- end
	-- if protocol.is_finish == 1 then
	-- 	--弹出成功界面
	-- 	ViewManager.Instance:Open(ViewName.FunOpenVictoryView)
	-- end
end

-- 精灵副本信息返回
function ExpresionFuBenCtrl:GetJingLingFuBenInfo(protocol)
	self.expresion_fu_ben_data:SetJingLingFuBenInfo(protocol)
	-- if ViewManager.Instance:IsOpen(ViewName.JingLingFuBenView) then
	-- 	self.jingling_fu_ben_view:Flush()
	-- end
	-- if protocol.is_finish == 1 then
	-- 	--弹出成功界面
	-- 	ViewManager.Instance:Open(ViewName.FunOpenVictoryView)
	-- end
end


function ExpresionFuBenCtrl:CloseFuBenView()
	-- if ViewManager.Instance:IsOpen(ViewName.MountFuBenView) then
	-- 	self.mount_fu_ben_view:Release()
	-- elseif ViewManager.Instance:IsOpen(ViewName.WingFuBenView) then
	-- 	self.wing_fu_ben_view:Release()
	-- elseif ViewManager.Instance:IsOpen(ViewName.JingLingFuBenView) then
	-- 	self.jingling_fu_ben_view:Release()
	-- end
end

-- 进入副本时，返回信息
function ExpresionFuBenCtrl:GetFBSceneLogicInfoReq(protocol)

end

function ExpresionFuBenCtrl:SceneLoadComplete(scene_id)

end