-- 专属打印 =========将 _printer_ 变量改成自己名字对应的字符，就能相应地打印出自己的信息===
local _printer_ = "zwx"
function _debug_( ... )
	if not GameConst.Debug then return end
	pt(...)
end
function zwx( ... ) if _printer_ == "zwx" then _debug_(...) end end
function zy( ... ) if _printer_ == "zy" then _debug_(...) end end
function lmj(...)	if _printer_ == "lmj" then _debug_(...) end end
function lsb(...) if _printer_ == "lsb" then _debug_(...) end end
function wq(...) if _printer_ == "wq" then _debug_(...) end end
function wh(...) if _printer_ == "wh" then _debug_(...) end end

--=====================================================

require "SKGame/Modules/Sys/View/DebugWindow"
require "SKGame/Modules/Sys/DebugView"
DebugMgr =BaseClass()
DebugMgr.StartDebug = false
function DebugMgr:__init()
	resMgr:AddUIAB("sys")
	self:Config()
	DebugMgr.StartDebug = true
end

function DebugMgr:Config()
	self.curMsg = ""
	local topLayer = layerMgr:GetTopLayer()
	self.btn = UIPackage.CreateObject("Sys","BtnDebug")
	self.btn.title = "调 试"
	self.btn:SetSize(80, 30)
	self.btn:SetXY(10, LayersMgr.HEIGHT - 160)
	topLayer:AddChild(self.btn)
	self.btn:AddRelation(topLayer, RelationType.Left_Left)
	self.btn:AddRelation(topLayer, RelationType.Top_Top)
	self.btn.onClick:Add(function ()
		self:Open()
	end)
	self.view = DebugView.New()
	self.step = 0

	local msgText = GTextField.New()
	topLayer:AddChild(msgText)
	local tf = TextFormat.New()
	tf.size = 24
	tf.color = Color.red
	tf.bold = true
	msgText.textFormat = tf
	msgText:SetXY(self.btn.x+self.btn.width + 30, self.btn.y)
	DebugMgr.msgText = msgText
	UpdateBeat:Add(self.Update, self)

	if GameConst.USE_PRELOAD then
		self.view.root:SetScale(1.8, 1.8)
	end
end

function DebugMgr.ShowRoleXYZ(x, y, z)
	DebugMgr.msgText.text = "x:"..NumberRoundFloat(x) .." y:"..NumberRoundFloat(y).." z:"..NumberRoundFloat(z)
end

function DebugMgr:Update()

	if self.fpsText == nil then return end
		self.step = self.step + 1
		if self.step > 10 then
			self.step = 0
		self.fpsText.text= StringFormat("Fps:{0}",math.floor(1/Time.deltaTime))
		end
end
function DebugMgr:Open()
	if self.view then
		self.view:Open()
	end
end

function DebugMgr:Close()
	if self.view then
		self.view:Close()
	end
end

-- 隐藏调试按钮，需要重启游戏才出来了。。。
function DebugMgr:Hide()
	if self.btn then
		self.btn:Dispose()
	end
	self.btn = nil
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
	self:Close()
end

function DebugMgr:AppendMsg( msg )
	print(msg)
	if self.view then
		self.view:AppendContent( msg )
	end
end

function DebugMgr:SetBtn( btn )
	self.btn = btn
end


function DebugMgr:GetInstance()
	if DebugMgr.inst == nil then
		DebugMgr.inst = DebugMgr.New()
	end
	return DebugMgr.inst
end
function DebugMgr:__delete()
	DebugMgr.inst = nil
	if self.view then
		self.view:Destroy()
	end
	DebugMgr.StartDebug = false
	self.view = nil
end