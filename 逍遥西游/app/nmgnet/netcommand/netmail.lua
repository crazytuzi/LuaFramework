local netmail = {}
function netmail.allmail(param, ptc_main, ptc_sub)
  print("netmail.allmail:", param, ptc_main, ptc_sub)
  if param then
    local mails = param.t_mail
    if mails then
      for k, v in pairs(mails) do
        g_MailMgr:recvMailData(v, false)
      end
    end
  end
end
function netmail.allmailover(param, ptc_main, ptc_sub)
  print("netmail.allmailover:", param, ptc_main, ptc_sub)
  g_MailMgr:recvAllMailFinished()
end
function netmail.updatemail(param, ptc_main, ptc_sub)
  print("netmail.updatemail:", param, ptc_main, ptc_sub)
  if param then
    g_MailMgr:recvMailData(param, true)
  end
end
function netmail.delmail(param, ptc_main, ptc_sub)
  print("netmail.delmail:", param, ptc_main, ptc_sub)
  if param then
    g_MailMgr:delMail(param.i_mid)
  end
end
function netmail.hasNewMail(param, ptc_main, ptc_sub)
  print("netmail.hasNewMail:", param, ptc_main, ptc_sub)
  g_MailMgr:hasNewMail()
end
return netmail
