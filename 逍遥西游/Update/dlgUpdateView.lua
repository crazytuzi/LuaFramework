dlgNewVersionView = class("dlgNewVersionView", CcsSubView)
function dlgNewVersionView:ctor(size, okListener, refuseListener)
  dlgNewVersionView.super.ctor(self, "views/newversion.json", {
    isAutoCenter = true,
    opacityBg = 0,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_ok = {
      listener = handler(self, self.Btn_Ok),
      variName = "btn_ok"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.okListener = okListener
  self.refuseListener = refuseListener
  self.tipsize = self:getNode("tipsize")
  self.tipsize:setText("需要下载更新补丁才能继续游戏")
end
function dlgNewVersionView:onEnterEvent()
  self:setVisible(true)
  self.bg = self:getNode("bg")
  local x, y = self.bg:getPosition()
  self.bg:setPosition(ccp(x, y + 100))
  local act1 = CCMoveTo:create(0.3, ccp(x, y))
  self.bg:runAction(CCEaseOut:create(act1, 3))
end
function dlgNewVersionView:Btn_Ok()
  if self.okListener then
    self.okListener()
  end
  self:CloseSelf()
end
function dlgNewVersionView:Clear()
  self.okListener = nil
  self.refuseListener = nil
end
local dlgUpdateView = class("dlgUpdateView", CcsSceneView)
function dlgUpdateView:ctor()
  dlgUpdateView.super.ctor(self, "views/game_update.json")
  self.pic_bg = self:getNode("pic_bg")
  local size = self.pic_bg:getContentSize()
  if size.width < display.width or size.height < display.height then
    self:getNode("pic_bg"):setSize(CCSize(display.width, display.height))
  end
  self:Show("None")
  self.m_DlSizeTips = self:getNode("txt_dlPro")
  self.m_CheckingTxt = self:getNode("txt_checkTips")
  self.m_PatchSize = self:getNode("txt_fileSize")
  self:getNode("txt_newVer"):setEnabled(false)
  local txt = "正在检查资源更新..."
  self.m_CheckingTxt:setText(txt)
  self.barpos = self:getNode("barpos")
  self.m_ProgressBar = ProgressClip.new("views/pic/pic_dl_loadingbar.png", "views/pic/pic_dl_loadingbg.png", 0, 100, true)
  self.barpos:addChild(self.m_ProgressBar, 1)
  self.m_ProgressBar:barOffset(0, -1)
  local size = self.m_ProgressBar:getSize()
  self.m_ProgressBar:setPosition(ccp(-size.width / 2, 0))
  self.m_ProgressBar:setVisible(false)
  self.pic_dl_loading = display.newSprite("views/pic/pic_dl_loading.png")
  self.barpos:addNode(self.pic_dl_loading, 2)
  self.pic_dl_loading:setPosition(ccp(0, -3))
  self.pic_dl_loading:setVisible(false)
  self:setCheckUpdateShow(true)
  self.m_PatchSize:setEnabled(false)
  self.m_DlSizeTips:setEnabled(false)
  resetLogoSpriteWithSpriteNode(self:getNode("pic_logo"))
end
function dlgUpdateView:setCurVer(verString)
  self:getNode("txt_curVer"):setText(string.format("当前版本:%s", verString))
end
function dlgUpdateView:setNewVer(verString)
  print("setNewVer")
end
function dlgUpdateView:setPatchSize(size)
  self.m_PatchSize:setEnabled(false)
  self.m_PatchSize:setVisible(false)
end
function dlgUpdateView:setCheckUpdateShow(isShow)
  self.m_CheckingTxt:setEnabled(isShow)
  if isShow then
    self.m_PatchSize:setEnabled(false)
    self.m_DlSizeTips:setEnabled(false)
    self.m_ProgressBar:setVisible(false)
    self.pic_dl_loading:setVisible(false)
  end
end
function dlgUpdateView:setDlProBarShow(isShow)
end
function dlgUpdateView:setDlPro(curDlSize, totalNeedSize)
  if totalNeedSize < curDlSize then
    curDlSize = totalNeedSize
  end
  local pro = 100 * curDlSize / totalNeedSize
  if pro > 100 then
    pro = 100
  end
  self:setDlSizeShow(pro, curDlSize, totalNeedSize)
end
function dlgUpdateView:setDlSizeShow(pro, curDlSize, totalNeedSize)
  local txt = ""
  txt = string.format("正在下载更新,请稍等片刻(%d%%)", checkint(pro))
  self.m_DlSizeTips:setText(txt)
  self.m_DlSizeTips:setEnabled(true)
  self.m_ProgressBar:setVisible(true)
  self.pic_dl_loading:setVisible(true)
  self.m_ProgressBar:value(checkint(pro))
end
function dlgUpdateView:setDownloadSucceed()
  print("-->>setDownloadSucceed:")
  self.m_DlSizeTips:setText("正在安装更新...")
  self.m_ProgressBar:value(100)
end
function dlgUpdateView:onCleanup()
  print("====>>dlgUpdateView:")
  self.m_CheckingTxt = nil
  self.m_DlSizeTips = nil
  self.m_ProBar = nil
  self:removeAllChildrenWithCleanup(true)
end
return dlgUpdateView
