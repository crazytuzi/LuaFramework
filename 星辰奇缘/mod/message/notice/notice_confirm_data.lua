-- -----------------------------
-- 确认框数据结构
-- hosr
-- -----------------------------
ConfirmData = ConfirmData or {}

ConfirmData.Style = {
    Normal = 0, -- 普通类型，确认取消按钮都显示
    Small = 0, -- 小窗口类型
    Sure = 2, -- 只显示确认按钮
}


NoticeConfirmData = NoticeConfirmData or BaseClass()

function NoticeConfirmData:__init()
    -- 显示类型
    self.type = ConfirmData.Style.Normal

    -- 文本内容
    self.content = ""
    --文本内容中的时间（只有一个的说）
    self.contentSecond = -1

    -- 确定按钮文本
    self.sureLabel = TI18N("确定")
    -- 取消按钮文本
    self.cancelLabel = TI18N("取消")

    -- 确认按钮点击回调
    self.sureCallback = nil
    -- 取消按钮回调
    self.cancelCallback = nil
    -- 关闭按钮回调
    self.closeCallback = nil

    -- 确定按钮执行倒计时, 整数秒
    self.sureSecond = -1
    -- 取消按钮执行倒计时,整数秒
    self.cancelSecond = -1

    -- 显示关闭按钮，不等于-1显示,子龙写的。。。
    self.showClose = -1

    -- 更换确认按钮颜色为蓝色
    self.blueSure = false
    -- 更换取消按钮颜色为绿色
    self.greenCancel = false
    -- 确认按钮显示特效
    self.showSureEffect = false
    -- 取消按钮显示特效
    self.showCancelEffect = false

    -- 是否显示toggle
    self.showToggle = false
    -- toggle显示内容
    self.toggleLabel = ""
    -- toggle变化回调
    self.toggleCallback = nil
    -- 取消倒计时不是取消操作
    self.cancelNoCancel = false
end

function NoticeConfirmData:Default()
    self.type = ConfirmData.Style.Normal
    self.content = ""
    self.contentSecond = -1
    self.sureLabel = TI18N("确定")
    self.cancelLabel = TI18N("取消")
    self.sureCallback = nil
    self.cancelCallback = nil
    self.closeCallback = nil
    self.sureSecond = -1
    self.cancelSecond = -1
    self.showClose = -1
    self.blueSure = false
    self.greenCancel = false
    self.showSureEffect = false
    self.showCancelEffect = false
    self.showToggle = false
    self.toggleLabel = ""
    self.toggleCallback = nil
    self.cancelNoCancel = false
end
