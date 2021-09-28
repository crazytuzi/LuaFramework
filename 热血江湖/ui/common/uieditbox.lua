
local UIBase = require "ui/common/UIBase"

local UIEditBox = class("UIEditBox", UIBase);
function UIEditBox:ctor(ccNode, propConfig)
    UIEditBox.super.ctor(self, ccNode, propConfig);
end

function UIEditBox:addEventListener(cb)
	self.ccNode_:registerScriptEditBoxHandler(cb)
end

function UIEditBox:setText(txt)
	if self.ccNode_ then
		self.ccNode_:setText(txt);
	end

	return self;
end

function UIEditBox:getText()
	if self.ccNode_ then
		return self.ccNode_:getText();
	end

	return "";
end

function UIEditBox:setPlaceHolder(text)
	self.ccNode_:setPlaceHolder(text)
end

function UIEditBox:getPlaceHolder()
	return self.ccNode_:getPlaceHolder()
end

function UIEditBox:setMaxLength(length)
	self.ccNode_:setMaxLength(length)
end

function UIEditBox:getMaxLength()
	return self.ccNode_:getMaxLength()
end


--[[
--  设置输入类型: flag从0开始设置
0  cc.EDITBOX_INPUT_FLAG_PASSWORD                   密码形式输入
1  cc.EDITBOX_INPUT_FLAG_SENSITIVE                  敏感数据输入、存储输入方案且预测自动完成 
2  cc.EDITBOX_INPUT_FLAG_INITIALCAPSWORD            每个单词首字母大写,并且伴有提示
3  cc.EDITBOX_INPUT_FLAG_INITIALCAPSSENTENCE        第一句首字母大写,并且伴有提示  
4  cc.EDITBOX_INPUT_FLAG_INITIALCAPSALLCHARACTERS   所有字符自动大写
5  cc.EDITBOX_INPUT_MODE_DECIMAL                    数字 输入类型键盘，允许小数点
--]]
function UIEditBox:setInputFlag(flag) 
	self.ccNode_:setInputFlag(flag)
	return self
end

--[[
--  设置输入模式
0  cc.EDITBOX_INPUT_MODE_ANY                        任何文本的输入键盘,包括换行
1  cc.EDITBOX_INPUT_MODE_EMAILADDR                  邮件地址 输入类型键盘
2  cc.EDITBOX_INPUT_MODE_NUMERIC                    数字符号 输入类型键盘
3  cc.EDITBOX_INPUT_MODE_PHONENUMBER                电话号码 输入类型键盘
4  cc.EDITBOX_INPUT_MODE_URL                        URL 输入类型键盘
5  cc.EDITBOX_INPUT_MODE_DECIMAL                    数字 输入类型键盘，允许小数点
6  cc.EDITBOX_INPUT_MODE_SINGLELINE                 任何文本的输入键盘,不包括换行
--]]
function UIEditBox:setInputMode(flag)
	self.ccNode_:setInputMode(flag)
	return self
end

return UIEditBox;
