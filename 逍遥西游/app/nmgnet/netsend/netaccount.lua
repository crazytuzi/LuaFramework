local netaccount = {}
function netaccount.register(s_gf, s_account, s_pwd, m_mk)
  NetSend({
    s_gf = s_gf,
    s_account = s_account,
    s_pwd = s_pwd,
    m_mk = m_mk
  }, S2C_Account, "P1")
end
function netaccount.loginNmg(s_gf, s_account, s_pwd, m_mk)
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  NetSend({
    s_gf = s_gf,
    s_account = s_account,
    s_pwd = s_pwd,
    t_v = ver,
    m_mk = m_mk
  }, S2C_Account, "P2")
end
function netaccount.loginMomo(s_gf, s_userid, s_vtoken, i_dtp)
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  NetSend({
    s_gf = s_gf,
    s_userid = s_userid,
    s_vtoken = s_vtoken,
    i_dtp = i_dtp,
    t_v = ver
  }, S2C_Account, "P4")
end
return netaccount
