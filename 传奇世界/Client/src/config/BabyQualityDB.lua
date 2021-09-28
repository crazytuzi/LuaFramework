local Items=
{
  {q_ID=1.0,q_name='紫府元婴',q_level=1.0,q_nextID=2.0,q_school=1.0,q_max_hp=135.0,q_attack_min=30.0,q_attack_max=60.0,q_defence_min=11.0,q_defence_max=23.0,q_magic_defence_min=6.0,q_magic_defence_max=13.0,q_succPer=50.0,q_failPer=50.0,},
  {q_ID=2.0,q_name='璇玑元婴',q_level=2.0,q_nextID=3.0,q_school=1.0,q_max_hp=350.0,q_attack_min=78.0,q_attack_max=156.0,q_defence_min=30.0,q_defence_max=60.0,q_magic_defence_min=17.0,q_magic_defence_max=33.0,q_succPer=40.0,q_failPer=25.0,q_degradePer=35.0,},
  {q_ID=3.0,q_name='灵虚元婴',q_level=3.0,q_nextID=4.0,q_school=1.0,q_max_hp=1423.0,q_attack_min=316.0,q_attack_max=632.0,q_defence_min=121.0,q_defence_max=242.0,q_magic_defence_min=67.0,q_magic_defence_max=134.0,q_succPer=10.0,q_failPer=20.0,q_degradePer=70.0,},
  {q_ID=4.0,q_name='神华元婴',q_level=4.0,q_nextID=5.0,q_school=1.0,q_max_hp=3447.0,q_attack_min=766.0,q_attack_max=1532.0,q_defence_min=294.0,q_defence_max=587.0,q_magic_defence_min=163.0,q_magic_defence_max=326.0,q_succPer=5.0,q_failPer=10.0,q_degradePer=85.0,},
  {q_ID=5.0,q_name='天启元婴',q_level=5.0,q_school=1.0,q_max_hp=6394.0,q_attack_min=1421.0,q_attack_max=2842.0,q_defence_min=545.0,q_defence_max=1089.0,q_magic_defence_min=302.0,q_magic_defence_max=604.0,},
  {q_ID=101.0,q_name='紫府元婴',q_level=1.0,q_nextID=102.0,q_school=2.0,q_max_hp=54.0,q_magic_attack_min=30.0,q_magic_attack_max=60.0,q_defence_min=9.0,q_defence_max=18.0,q_magic_defence_min=12.0,q_magic_defence_max=24.0,q_succPer=50.0,q_failPer=50.0,},
  {q_ID=102.0,q_name='璇玑元婴',q_level=2.0,q_nextID=103.0,q_school=2.0,q_max_hp=140.0,q_magic_attack_min=78.0,q_magic_attack_max=156.0,q_defence_min=23.0,q_defence_max=47.0,q_magic_defence_min=31.0,q_magic_defence_max=62.0,q_succPer=40.0,q_failPer=25.0,q_degradePer=35.0,},
  {q_ID=103.0,q_name='灵虚元婴',q_level=3.0,q_nextID=104.0,q_school=2.0,q_max_hp=569.0,q_magic_attack_min=316.0,q_magic_attack_max=632.0,q_defence_min=95.0,q_defence_max=190.0,q_magic_defence_min=126.0,q_magic_defence_max=253.0,q_succPer=10.0,q_failPer=20.0,q_degradePer=70.0,},
  {q_ID=104.0,q_name='神华元婴',q_level=4.0,q_nextID=105.0,q_school=2.0,q_max_hp=1379.0,q_magic_attack_min=766.0,q_magic_attack_max=1532.0,q_defence_min=230.0,q_defence_max=460.0,q_magic_defence_min=306.0,q_magic_defence_max=613.0,q_succPer=5.0,q_failPer=10.0,q_degradePer=85.0,},
  {q_ID=105.0,q_name='天启元婴',q_level=5.0,q_school=2.0,q_max_hp=2557.0,q_magic_attack_min=1421.0,q_magic_attack_max=2842.0,q_defence_min=426.0,q_defence_max=852.0,q_magic_defence_min=568.0,q_magic_defence_max=1137.0,},
  {q_ID=201.0,q_name='紫府元婴',q_level=1.0,q_nextID=202.0,q_school=3.0,q_max_hp=90.0,q_sc_attack_min='30',q_sc_attack_max='60',q_defence_min=10.0,q_defence_max=21.0,q_magic_defence_min=12.0,q_magic_defence_max=24.0,q_succPer=50.0,q_failPer=50.0,},
  {q_ID=202.0,q_name='璇玑元婴',q_level=2.0,q_nextID=203.0,q_school=3.0,q_max_hp=233.0,q_sc_attack_min='78',q_sc_attack_max='156',q_defence_min=27.0,q_defence_max=54.0,q_magic_defence_min=31.0,q_magic_defence_max=62.0,q_succPer=40.0,q_failPer=25.0,q_degradePer=35.0,},
  {q_ID=203.0,q_name='灵虚元婴',q_level=3.0,q_nextID=204.0,q_school=3.0,q_max_hp=948.0,q_sc_attack_min='316',q_sc_attack_max='632',q_defence_min=110.0,q_defence_max=220.0,q_magic_defence_min=125.0,q_magic_defence_max=250.0,q_succPer=10.0,q_failPer=20.0,q_degradePer=70.0,},
  {q_ID=204.0,q_name='神华元婴',q_level=4.0,q_nextID=205.0,q_school=3.0,q_max_hp=2298.0,q_sc_attack_min='766',q_sc_attack_max='1532',q_defence_min=267.0,q_defence_max=534.0,q_magic_defence_min=303.0,q_magic_defence_max=607.0,q_succPer=5.0,q_failPer=10.0,q_degradePer=85.0,},
  {q_ID=205.0,q_name='天启元婴',q_level=5.0,q_school=3.0,q_max_hp=4262.0,q_sc_attack_min='1421',q_sc_attack_max='2842',q_defence_min=495.0,q_defence_max=990.0,q_magic_defence_min=563.0,q_magic_defence_max=1126.0,},
}

return Items