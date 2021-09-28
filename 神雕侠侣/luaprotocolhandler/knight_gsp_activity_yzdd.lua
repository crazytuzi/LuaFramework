local p = require "protocoldef.knight.gsp.activity.yzdd.scountdown"
function p:process()
	LogInfo("protocoldef.knight.gsp.activity.yzdd.scountdown process start")
	local YiZhanDaoDiTimeDlg = require "ui.yizhandaodi.yizhandaoditime"
	YiZhanDaoDiTimeDlg.getInstanceAndShow():Refresh(self.remaintime, self.rolenum)
	LogInfo("protocoldef.knight.gsp.activity.yzdd.scountdown process end")
end

local p = require "protocoldef.knight.gsp.activity.yzdd.syzddquestion"
function p:process()
	LogInfo("protocoldef.knight.gsp.activity.yzdd.squestion process start")
	local YiZhanDaoDiAnswerDlg = require "ui.yizhandaodi.yizhandaodianswer"
	YiZhanDaoDiAnswerDlg.getInstanceAndShow():NewQuestion(self.question, self.sn, self.status)
	LogInfo("protocoldef.knight.gsp.activity.yzdd.squestion process end")
end

local p = require "protocoldef.knight.gsp.activity.yzdd.sanswerstatitics"
function p:process()
	LogInfo("protocoldef.knight.gsp.activity.yzdd.sanswerstatitics process start")
	local YiZhanDaoDiAnswerDlg = require "ui.yizhandaodi.yizhandaodianswer"
	print("self.question = " .. self.question)
	print("self.a = " .. self.a)
	print("self.b = " .. self.b)
	print("self.c = " .. self.c)
	print("self.d = " .. self.d)
	YiZhanDaoDiAnswerDlg.getInstanceAndShow():Refresh(self.question, self.a, self.b, self.c, self.d)
	LogInfo("protocoldef.knight.gsp.activity.yzdd.sanswerstatitics process end")
end

local p = require "protocoldef.knight.gsp.activity.yzdd.sresut"
function p:process()
	LogInfo("protocoldef.knight.gsp.activity.yzdd.sresut process start")
	local YiZhanDaoDiAnswerDlg = require "ui.yizhandaodi.yizhandaodianswer"
	YiZhanDaoDiAnswerDlg.getInstanceAndShow():Result(self.question, self.answer, self.rightnum, self.wrongnum, self.status)
	LogInfo("protocoldef.knight.gsp.activity.yzdd.sresut process end")
end
