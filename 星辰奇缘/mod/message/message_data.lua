-- ---------------------------
-- 信息数据结构
-- hosr
-- ---------------------------
MsgData = MsgData or BaseClass()

function MsgData:__init()
    -- 源字符串
    self.sourceString = ""
    -- 格式化后的显示字符串
    self.showString = ""
    -- 纯字符串内容，不带颜色
    self.pureString = ""
    -- 总长
    self.allHeight = 0
    -- 总宽
    self.allWidth = 0
    -- --------------------
    -- 元素列表
    -- 目前的元素是图片或表情，都是gameObject
    -- --------------------
    self.elements = {}
end
