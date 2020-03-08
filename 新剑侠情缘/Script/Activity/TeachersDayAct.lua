local tbAct = Activity:GetUiSetting("TeachersDayAct")

tbAct.nShowLevel = 1
tbAct.szTitle = "欢庆师徒节"
tbAct.szUiName = "Normal"
tbAct.FnCustomData = function (_, tbData)
    local szStart   = Lib:TimeDesc7(tbData.nStartTime)
    local szEnd     = Lib:TimeDesc7(tbData.nEndTime + 1)
    local szContent = "     “桃李满天下，春晖遍四方”，无论是生活中的长辈，还是工作中的前辈，抑或是纷乱江湖中与你结缘的师父，曾对我们提携指点、排忧解难的人都是我们的恩师。正值九月十日，师徒管理员上官飞龙特为各位师徒准备了考验默契与配合的副本—[FFFE0D]【师徒试炼】[-]，以验从师之果！更有丰厚的奖励等着大家，共庆师徒佳节。\n     活动简介：活动期间内，师徒关系的两位玩家（包括出师）[FFFE0D]互赠5棵玫瑰花/幸运草[-]（99棵玫瑰花/幸运草无效），徒弟即可获得[ff8f06] [url=openwnd:师徒信物, ItemTips, 'Item', nil, 6232] [-]。师徒2人可组队前往上官飞龙处上交[ff8f06] [url=openwnd:师徒信物, ItemTips, 'Item', nil, 6232] [-]以参与挑战师徒试炼。\n     注意事项：\n     （1）参与副本的队伍中必须有且仅有师徒2人；\n     （2）徒弟必须携带师徒信物；\n     （3）首次挑战成功将获得丰厚的首次奖励及基础奖励，后续参与挑战副本只会获得基础奖励；\n     （4）整个活动期间，徒弟最多获得5个信物，师父最多可获得10次奖励；\n     （5）师父挑战5次、10次师徒试炼可获得[FFFE0D]良师益友（限时1个月）[-]、[FFFE0D]百世之师（限时1个月）[-]特殊称号，徒弟挑战5次可获得[FFFE0D]得意门生（限时1个月）[-]特殊称号；\n     （6）试炼挑战过程中退出副本或限定时间内未通过试炼将视为挑战失败且无奖励；\n     （7）请各位师徒精诚协作，各显身手，在副本中要多多思考并注意相关提示哦！"
    return {string.format("活动时间：[c8ff00]%s-%s[-]\n\n%s", szStart, szEnd, szContent)}
end