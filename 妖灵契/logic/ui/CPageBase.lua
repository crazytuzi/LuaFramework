local CPageBase = class("CPageBase", CWidget, CGameObjContainer)

function CPageBase.ctor(self, obj)
	CWidget.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_IsInit = false
	self.m_IsShow = false
	self.m_ParentView = nil
end

function CPageBase.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CPageBase.ShowPage(self)
    self:SetActive(true) 
    if not self.m_IsInit then
        self:OnInitPage()
        self:DelayCall(0.35,  "DelayInitPage")
        self.m_IsInit = true
    end
    self.m_IsShow = true
    self:OnShowPage()
end


function CPageBase.HidePage(self)
	self.m_IsShow = false
	self:SetActive(false)
	self:OnHidePage()
	self:StopDelayCall("DelayInitPage")
end

function CPageBase.IsInit(self)
	return self.m_IsInit
end

function CPageBase.IsShow(self)
	return self.m_IsShow
end

--override
function CPageBase.OnInitPage(self)

	--初始化各个子控件
end

function CPageBase.DelayInitPage(self)
	--延迟执行的初始化，保证切分页不卡
end

function CPageBase.OnShowPage(self)
	-- 显示界面
	-- print("OnShowPage"..self.classname)
end

function CPageBase.OnHidePage(self)
	-- 隐藏界面
	-- print("OnHidePage"..self.classname)
end

function CPageBase.Destroy(self)
	-- 销毁界面
	-- print("Destroy"..self.classname)
	self:StopDelayCall("DelayInitPage")
	CObject.Destroy(self)
end


return CPageBase