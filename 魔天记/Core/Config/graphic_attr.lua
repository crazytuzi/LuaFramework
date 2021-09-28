local graphic_attr={
[0]={0,10,0,0,0,0,0,0},
[1]={1,15,719,47,28,500,200,1000},
[2]={2,20,1438,94,56,557,201,1020},
[3]={3,25,2157,141,84,614,203,1040},
[4]={4,30,2876,188,112,671,204,1060},
[5]={5,35,3595,235,140,728,206,1080},
[6]={6,40,4314,282,168,785,207,1100},
[7]={7,45,5033,329,196,842,209,1120},
[8]={8,50,5752,376,224,899,210,1140},
[9]={9,55,6471,423,252,956,212,1160},
[10]={10,60,7190,470,280,1013,213,1180},
[11]={11,65,7909,517,308,1070,215,1200},
[12]={12,70,8628,564,336,1127,216,1220},
[13]={13,75,9347,611,364,1184,218,1240},
[14]={14,80,10066,658,392,1241,219,1260},
[15]={15,85,10785,705,420,1298,221,1280},
[16]={16,90,11504,752,448,1355,222,1300},
[17]={17,95,12223,799,476,1412,224,1320},
[18]={18,100,12942,846,504,1469,225,1340},
[19]={19,105,13661,893,532,1526,227,1360},
[20]={20,110,14380,940,560,1583,228,1380},
[21]={21,115,15099,987,588,1640,230,1400},
[22]={22,120,15818,1034,616,1697,231,1420},
[23]={23,125,16537,1081,644,1754,233,1440},
[24]={24,130,17256,1128,672,1811,234,1460},
[25]={25,135,17975,1175,700,1868,236,1480},
[26]={26,140,18694,1222,728,1925,237,1500},
[27]={27,145,19413,1269,756,1982,239,1520},
[28]={28,150,20132,1316,784,2039,240,1540},
[29]={29,155,20851,1363,812,2096,242,1560},
[30]={30,160,21570,1410,840,2153,243,1580},
[31]={31,165,22289,1457,868,2210,245,1600},
[32]={32,170,23008,1504,896,2267,246,1620},
[33]={33,175,23727,1551,924,2324,248,1640},
[34]={34,180,24446,1598,952,2381,249,1660},
[35]={35,185,25165,1645,980,2438,251,1680},
[36]={36,190,25884,1692,1008,2495,252,1700},
[37]={37,195,26603,1739,1036,2552,254,1720},
[38]={38,200,27322,1786,1064,2609,255,1740},
[39]={39,205,28041,1833,1092,2666,257,1760},
[40]={40,210,28760,1880,1120,2723,258,1780},
[41]={41,215,29479,1927,1148,2780,260,1800},
[42]={42,220,30198,1974,1176,2837,261,1820},
[43]={43,225,30917,2021,1204,2894,263,1840},
[44]={44,230,31636,2068,1232,2951,264,1860},
[45]={45,235,32355,2115,1260,3008,266,1880},
[46]={46,240,33074,2162,1288,3065,267,1900},
[47]={47,245,33793,2209,1316,3122,269,1920},
[48]={48,250,34512,2256,1344,3179,270,1940},
[49]={49,255,35231,2303,1372,3236,272,1960},
[50]={50,260,35950,2350,1400,3293,273,1980},
[51]={51,265,36669,2397,1428,3350,275,2000},
[52]={52,270,37388,2444,1456,3407,276,2020},
[53]={53,275,38107,2491,1484,3464,278,2040},
[54]={54,280,38826,2538,1512,3521,279,2060},
[55]={55,285,39545,2585,1540,3578,281,2080},
[56]={56,290,40264,2632,1568,3635,282,2100},
[57]={57,295,40983,2679,1596,3692,284,2120},
[58]={58,300,41702,2726,1624,3749,285,2140},
[59]={59,305,42421,2773,1652,3806,287,2160},
[60]={60,310,43140,2820,1680,3863,288,2180},
[61]={61,315,43859,2867,1708,3920,290,2200},
[62]={62,320,44578,2914,1736,3977,291,2220},
[63]={63,325,45297,2961,1764,4034,293,2240},
[64]={64,330,46016,3008,1792,4091,294,2260},
[65]={65,335,46735,3055,1820,4148,296,2280},
[66]={66,340,47454,3102,1848,4205,297,2300},
[67]={67,345,48173,3149,1876,4262,299,2320},
[68]={68,350,48892,3196,1904,4319,300,2340},
[69]={69,355,49611,3243,1932,4376,302,2360},
[70]={70,360,50330,3290,1960,4433,303,2380},
[71]={71,365,51049,3337,1988,4490,305,2400},
[72]={72,370,51768,3384,2016,4547,306,2420},
[73]={73,375,52487,3431,2044,4604,308,2440},
[74]={74,380,53206,3478,2072,4661,309,2460},
[75]={75,385,53925,3525,2100,4718,311,2480},
[76]={76,390,54644,3572,2128,4775,312,2500},
[77]={77,395,55363,3619,2156,4832,314,2520},
[78]={78,400,56082,3666,2184,4889,315,2540},
[79]={79,405,56801,3713,2212,4946,317,2560},
[80]={80,410,57520,3760,2240,5003,318,2580},
[81]={81,415,58239,3807,2268,5060,320,2600},
[82]={82,420,58958,3854,2296,5117,321,2620},
[83]={83,425,59677,3901,2324,5174,323,2640},
[84]={84,430,60396,3948,2352,5231,324,2660},
[85]={85,435,61115,3995,2380,5288,326,2680},
[86]={86,440,61834,4042,2408,5345,327,2700},
[87]={87,445,62553,4089,2436,5402,329,2720},
[88]={88,450,63272,4136,2464,5459,330,2740},
[89]={89,455,63991,4183,2492,5516,332,2760},
[90]={90,460,64710,4230,2520,5573,333,2780},
[91]={91,465,65429,4277,2548,5630,335,2800},
[92]={92,470,66148,4324,2576,5687,336,2820},
[93]={93,475,66867,4371,2604,5744,338,2840},
[94]={94,480,67586,4418,2632,5801,339,2860},
[95]={95,485,68305,4465,2660,5858,341,2880},
[96]={96,490,69024,4512,2688,5915,342,2900},
[97]={97,495,69743,4559,2716,5972,344,2920},
[98]={98,500,70462,4606,2744,6029,345,2940},
[99]={99,505,71181,4653,2772,6086,347,2960},
[100]={100,510,71900,4700,2800,6143,348,2980},
[101]={101,515,72619,4747,2828,6200,350,3000},
[102]={102,520,73338,4794,2856,6257,351,3020},
[103]={103,525,74057,4841,2884,6314,353,3040},
[104]={104,530,74776,4888,2912,6371,354,3060},
[105]={105,535,75495,4935,2940,6428,356,3080},
[106]={106,540,76214,4982,2968,6485,357,3100},
[107]={107,545,76933,5029,2996,6542,359,3120},
[108]={108,550,77652,5076,3024,6599,360,3140},
[109]={109,555,78371,5123,3052,6656,362,3160},
[110]={110,560,79090,5170,3080,6713,363,3180},
[111]={111,565,79809,5217,3108,6770,365,3200},
[112]={112,570,80528,5264,3136,6827,366,3220},
[113]={113,575,81247,5311,3164,6884,368,3240},
[114]={114,580,81966,5358,3192,6941,369,3260},
[115]={115,585,82685,5405,3220,6998,371,3280},
[116]={116,590,83404,5452,3248,7055,372,3300},
[117]={117,595,84123,5499,3276,7112,374,3320},
[118]={118,600,84842,5546,3304,7169,375,3340},
[119]={119,605,85561,5593,3332,7226,377,3360},
[120]={120,610,86280,5640,3360,7283,378,3380},
[121]={121,615,86999,5687,3388,7340,380,3400},
[122]={122,620,87718,5734,3416,7397,381,3420},
[123]={123,625,88437,5781,3444,7454,383,3440},
[124]={124,630,89156,5828,3472,7511,384,3460},
[125]={125,635,89875,5875,3500,7568,386,3480},
[126]={126,640,90594,5922,3528,7625,387,3500},
[127]={127,645,91313,5969,3556,7682,389,3520},
[128]={128,650,92032,6016,3584,7739,390,3540},
[129]={129,655,92751,6063,3612,7796,392,3560},
[130]={130,660,93470,6110,3640,7853,393,3580},
[131]={131,665,94189,6157,3668,7910,395,3600},
[132]={132,670,94908,6204,3696,7967,396,3620},
[133]={133,675,95627,6251,3724,8024,398,3640},
[134]={134,680,96346,6298,3752,8081,399,3660},
[135]={135,685,97065,6345,3780,8138,401,3680},
[136]={136,690,97784,6392,3808,8195,402,3700},
[137]={137,695,98503,6439,3836,8252,404,3720},
[138]={138,700,99222,6486,3864,8309,405,3740},
[139]={139,705,99941,6533,3892,8366,407,3760},
[140]={140,710,100660,6580,3920,8423,408,3780},
[141]={141,715,101379,6627,3948,8480,410,3800},
[142]={142,720,102098,6674,3976,8537,411,3820},
[143]={143,725,102817,6721,4004,8594,413,3840},
[144]={144,730,103536,6768,4032,8651,414,3860},
[145]={145,735,104255,6815,4060,8708,416,3880},
[146]={146,740,104974,6862,4088,8765,417,3900},
[147]={147,745,105693,6909,4116,8822,419,3920},
[148]={148,750,106412,6956,4144,8879,420,3940},
[149]={149,755,107131,7003,4172,8936,422,3960},
[150]={150,760,107850,7050,4200,8993,423,3980},
[151]={151,765,108569,7097,4228,9050,425,4000},
[152]={152,770,109288,7144,4256,9107,426,4020},
[153]={153,775,110007,7191,4284,9164,428,4040},
[154]={154,780,110726,7238,4312,9221,429,4060},
[155]={155,785,111445,7285,4340,9278,431,4080},
[156]={156,790,112164,7332,4368,9335,432,4100},
[157]={157,795,112883,7379,4396,9392,434,4120},
[158]={158,800,113602,7426,4424,9449,435,4140},
[159]={159,805,114321,7473,4452,9506,437,4160},
[160]={160,810,115040,7520,4480,9563,438,4180},
[161]={161,815,115759,7567,4508,9620,440,4200},
[162]={162,820,116478,7614,4536,9677,441,4220},
[163]={163,825,117197,7661,4564,9734,443,4240},
[164]={164,830,117916,7708,4592,9791,444,4260},
[165]={165,835,118635,7755,4620,9848,446,4280},
[166]={166,840,119354,7802,4648,9905,447,4300},
[167]={167,845,120073,7849,4676,9962,449,4320},
[168]={168,850,120792,7896,4704,10019,450,4340},
[169]={169,855,121511,7943,4732,10076,452,4360},
[170]={170,860,122230,7990,4760,10133,453,4380},
[171]={171,865,122949,8037,4788,10190,455,4400},
[172]={172,870,123668,8084,4816,10247,456,4420},
[173]={173,875,124387,8131,4844,10304,458,4440},
[174]={174,880,125106,8178,4872,10361,459,4460},
[175]={175,885,125825,8225,4900,10418,461,4480},
[176]={176,890,126544,8272,4928,10475,462,4500},
[177]={177,895,127263,8319,4956,10532,464,4520},
[178]={178,900,127982,8366,4984,10589,465,4540},
[179]={179,905,128701,8413,5012,10646,467,4560},
[180]={180,910,129420,8460,5040,10703,468,4580},
[181]={181,915,130139,8507,5068,10760,470,4600},
[182]={182,920,130858,8554,5096,10817,471,4620},
[183]={183,925,131577,8601,5124,10874,473,4640},
[184]={184,930,132296,8648,5152,10931,474,4660},
[185]={185,935,133015,8695,5180,10988,476,4680},
[186]={186,940,133734,8742,5208,11045,477,4700},
[187]={187,945,134453,8789,5236,11102,479,4720},
[188]={188,950,135172,8836,5264,11159,480,4740},
[189]={189,955,135891,8883,5292,11216,482,4760},
[190]={190,960,136610,8930,5320,11273,483,4780},
[191]={191,965,137329,8977,5348,11330,485,4800},
[192]={192,970,138048,9024,5376,11387,486,4820},
[193]={193,975,138767,9071,5404,11444,488,4840},
[194]={194,980,139486,9118,5432,11501,489,4860},
[195]={195,985,140205,9165,5460,11558,491,4880},
[196]={196,990,140924,9212,5488,11615,492,4900},
[197]={197,995,141643,9259,5516,11672,494,4920},
[198]={198,1000,142362,9306,5544,11729,495,4940},
[199]={199,1005,143081,9353,5572,11786,497,4960},
[200]={200,1010,143800,9400,5600,11843,498,4980},
[201]={201,1015,144519,9447,5628,11900,500,5000},
[202]={202,1020,145238,9494,5656,11957,501,5020},
[203]={203,1025,145957,9541,5684,12014,503,5040},
[204]={204,1030,146676,9588,5712,12071,504,5060},
[205]={205,1035,147395,9635,5740,12128,506,5080},
[206]={206,1040,148114,9682,5768,12185,507,5100},
[207]={207,1045,148833,9729,5796,12242,509,5120},
[208]={208,1050,149552,9776,5824,12299,510,5140},
[209]={209,1055,150271,9823,5852,12356,512,5160},
[210]={210,1060,150990,9870,5880,12413,513,5180},
[211]={211,1065,151709,9917,5908,12470,515,5200},
[212]={212,1070,152428,9964,5936,12527,516,5220},
[213]={213,1075,153147,10011,5964,12584,518,5240},
[214]={214,1080,153866,10058,5992,12641,519,5260},
[215]={215,1085,154585,10105,6020,12698,521,5280},
[216]={216,1090,155304,10152,6048,12755,522,5300},
[217]={217,1095,156023,10199,6076,12812,524,5320},
[218]={218,1100,156742,10246,6104,12869,525,5340},
[219]={219,1105,157461,10293,6132,12926,527,5360},
[220]={220,1110,158180,10340,6160,12983,528,5380},
[221]={221,1115,158899,10387,6188,13040,530,5400},
[222]={222,1120,159618,10434,6216,13097,531,5420},
[223]={223,1125,160337,10481,6244,13154,533,5440},
[224]={224,1130,161056,10528,6272,13211,534,5460},
[225]={225,1135,161775,10575,6300,13268,536,5480},
[226]={226,1140,162494,10622,6328,13325,537,5500},
[227]={227,1145,163213,10669,6356,13382,539,5520},
[228]={228,1150,163932,10716,6384,13439,540,5540},
[229]={229,1155,164651,10763,6412,13496,542,5560},
[230]={230,1160,165370,10810,6440,13553,543,5580},
[231]={231,1165,166089,10857,6468,13610,545,5600},
[232]={232,1170,166808,10904,6496,13667,546,5620},
[233]={233,1175,167527,10951,6524,13724,548,5640},
[234]={234,1180,168246,10998,6552,13781,549,5660},
[235]={235,1185,168965,11045,6580,13838,551,5680},
[236]={236,1190,169684,11092,6608,13895,552,5700},
[237]={237,1195,170403,11139,6636,13952,554,5720},
[238]={238,1200,171122,11186,6664,14009,555,5740},
[239]={239,1205,171841,11233,6692,14066,557,5760},
[240]={240,1210,172560,11280,6720,14123,558,5780},
[241]={241,1215,173279,11327,6748,14180,560,5800},
[242]={242,1220,173998,11374,6776,14237,561,5820},
[243]={243,1225,174717,11421,6804,14294,563,5840},
[244]={244,1230,175436,11468,6832,14351,564,5860},
[245]={245,1235,176155,11515,6860,14408,566,5880},
[246]={246,1240,176874,11562,6888,14465,567,5900},
[247]={247,1245,177593,11609,6916,14522,569,5920},
[248]={248,1250,178312,11656,6944,14579,570,5940},
[249]={249,1255,179031,11703,6972,14636,572,5960},
[250]={250,1260,179750,11750,7000,14693,573,5980},
[251]={251,1265,180469,11797,7028,14750,575,6000},
[252]={252,1270,181188,11844,7056,14807,576,6020},
[253]={253,1275,181907,11891,7084,14864,578,6040},
[254]={254,1280,182626,11938,7112,14921,579,6060},
[255]={255,1285,183345,11985,7140,14978,581,6080},
[256]={256,1290,184064,12032,7168,15035,582,6100},
[257]={257,1295,184783,12079,7196,15092,584,6120},
[258]={258,1300,185502,12126,7224,15149,585,6140},
[259]={259,1305,186221,12173,7252,15206,587,6160},
[260]={260,1310,186940,12220,7280,15263,588,6180},
[261]={261,1315,187659,12267,7308,15320,590,6200},
[262]={262,1320,188378,12314,7336,15377,591,6220},
[263]={263,1325,189097,12361,7364,15434,593,6240},
[264]={264,1330,189816,12408,7392,15491,594,6260},
[265]={265,1335,190535,12455,7420,15548,596,6280},
[266]={266,1340,191254,12502,7448,15605,597,6300},
[267]={267,1345,191973,12549,7476,15662,599,6320},
[268]={268,1350,192692,12596,7504,15719,600,6340},
[269]={269,1355,193411,12643,7532,15776,602,6360},
[270]={270,1360,194130,12690,7560,15833,603,6380},
[271]={271,1365,194849,12737,7588,15890,605,6400},
[272]={272,1370,195568,12784,7616,15947,606,6420},
[273]={273,1375,196287,12831,7644,16004,608,6440},
[274]={274,1380,197006,12878,7672,16061,609,6460},
[275]={275,1385,197725,12925,7700,16118,611,6480},
[276]={276,1390,198444,12972,7728,16175,612,6500},
[277]={277,1395,199163,13019,7756,16232,614,6520},
[278]={278,1400,199882,13066,7784,16289,615,6540},
[279]={279,1405,200601,13113,7812,16346,617,6560},
[280]={280,1410,201320,13160,7840,16403,618,6580},
[281]={281,1415,202039,13207,7868,16460,620,6600},
[282]={282,1420,202758,13254,7896,16517,621,6620},
[283]={283,1425,203477,13301,7924,16574,623,6640},
[284]={284,1430,204196,13348,7952,16631,624,6660},
[285]={285,1435,204915,13395,7980,16688,626,6680},
[286]={286,1440,205634,13442,8008,16745,627,6700},
[287]={287,1445,206353,13489,8036,16802,629,6720},
[288]={288,1450,207072,13536,8064,16859,630,6740},
[289]={289,1455,207791,13583,8092,16916,632,6760},
[290]={290,1460,208510,13630,8120,16973,633,6780},
[291]={291,1465,209229,13677,8148,17030,635,6800},
[292]={292,1470,209948,13724,8176,17087,636,6820},
[293]={293,1475,210667,13771,8204,17144,638,6840},
[294]={294,1480,211386,13818,8232,17201,639,6860},
[295]={295,1485,212105,13865,8260,17258,641,6880},
[296]={296,1490,212824,13912,8288,17315,642,6900},
[297]={297,1495,213543,13959,8316,17372,644,6920},
[298]={298,1500,214262,14006,8344,17429,645,6940},
[299]={299,1505,214981,14053,8372,17486,647,6960},
[300]={300,1510,215700,14100,8400,17543,648,6980},
[301]={301,1515,216419,14147,8428,17600,650,7000},
[302]={302,1520,217138,14194,8456,17657,651,7020},
[303]={303,1525,217857,14241,8484,17714,653,7040},
[304]={304,1530,218576,14288,8512,17771,654,7060},
[305]={305,1535,219295,14335,8540,17828,656,7080},
[306]={306,1540,220014,14382,8568,17885,657,7100},
[307]={307,1545,220733,14429,8596,17942,659,7120},
[308]={308,1550,221452,14476,8624,17999,660,7140},
[309]={309,1555,222171,14523,8652,18056,662,7160},
[310]={310,1560,222890,14570,8680,18113,663,7180},
[311]={311,1565,223609,14617,8708,18170,665,7200},
[312]={312,1570,224328,14664,8736,18227,666,7220},
[313]={313,1575,225047,14711,8764,18284,668,7240},
[314]={314,1580,225766,14758,8792,18341,669,7260},
[315]={315,1585,226485,14805,8820,18398,671,7280},
[316]={316,1590,227204,14852,8848,18455,672,7300},
[317]={317,1595,227923,14899,8876,18512,674,7320},
[318]={318,1600,228642,14946,8904,18569,675,7340},
[319]={319,1605,229361,14993,8932,18626,677,7360},
[320]={320,1610,230080,15040,8960,18683,678,7380},
[321]={321,1615,230799,15087,8988,18740,680,7400},
[322]={322,1620,231518,15134,9016,18797,681,7420},
[323]={323,1625,232237,15181,9044,18854,683,7440},
[324]={324,1630,232956,15228,9072,18911,684,7460},
[325]={325,1635,233675,15275,9100,18968,686,7480},
[326]={326,1640,234394,15322,9128,19025,687,7500},
[327]={327,1645,235113,15369,9156,19082,689,7520},
[328]={328,1650,235832,15416,9184,19139,690,7540},
[329]={329,1655,236551,15463,9212,19196,692,7560},
[330]={330,1660,237270,15510,9240,19253,693,7580},
[331]={331,1665,237989,15557,9268,19310,695,7600},
[332]={332,1670,238708,15604,9296,19367,696,7620},
[333]={333,1675,239427,15651,9324,19424,698,7640},
[334]={334,1680,240146,15698,9352,19481,699,7660},
[335]={335,1685,240865,15745,9380,19538,701,7680},
[336]={336,1690,241584,15792,9408,19595,702,7700},
[337]={337,1695,242303,15839,9436,19652,704,7720},
[338]={338,1700,243022,15886,9464,19709,705,7740},
[339]={339,1705,243741,15933,9492,19766,707,7760},
[340]={340,1710,244460,15980,9520,19823,708,7780},
[341]={341,1715,245179,16027,9548,19880,710,7800},
[342]={342,1720,245898,16074,9576,19937,711,7820},
[343]={343,1725,246617,16121,9604,19994,713,7840},
[344]={344,1730,247336,16168,9632,20051,714,7860},
[345]={345,1735,248055,16215,9660,20108,716,7880},
[346]={346,1740,248774,16262,9688,20165,717,7900},
[347]={347,1745,249493,16309,9716,20222,719,7920},
[348]={348,1750,250212,16356,9744,20279,720,7940},
[349]={349,1755,250931,16403,9772,20336,722,7960},
[350]={350,1760,251650,16450,9800,20393,723,7980},
[351]={351,1765,252369,16497,9828,20450,725,8000},
[352]={352,1770,253088,16544,9856,20507,726,8020},
[353]={353,1775,253807,16591,9884,20564,728,8040},
[354]={354,1780,254526,16638,9912,20621,729,8060},
[355]={355,1785,255245,16685,9940,20678,731,8080},
[356]={356,1790,255964,16732,9968,20735,732,8100},
[357]={357,1795,256683,16779,9996,20792,734,8120},
[358]={358,1800,257402,16826,10024,20849,735,8140},
[359]={359,1805,258121,16873,10052,20906,737,8160},
[360]={360,1810,258840,16920,10080,20963,738,8180},
[361]={361,1815,259559,16967,10108,21020,740,8200},
[362]={362,1820,260278,17014,10136,21077,741,8220},
[363]={363,1825,260997,17061,10164,21134,743,8240},
[364]={364,1830,261716,17108,10192,21191,744,8260},
[365]={365,1835,262435,17155,10220,21248,746,8280},
[366]={366,1840,263154,17202,10248,21305,747,8300},
[367]={367,1845,263873,17249,10276,21362,749,8320},
[368]={368,1850,264592,17296,10304,21419,750,8340},
[369]={369,1855,265311,17343,10332,21476,752,8360},
[370]={370,1860,266030,17390,10360,21533,753,8380},
[371]={371,1865,266749,17437,10388,21590,755,8400},
[372]={372,1870,267468,17484,10416,21647,756,8420},
[373]={373,1875,268187,17531,10444,21704,758,8440},
[374]={374,1880,268906,17578,10472,21761,759,8460},
[375]={375,1885,269625,17625,10500,21818,761,8480},
[376]={376,1890,270344,17672,10528,21875,762,8500},
[377]={377,1895,271063,17719,10556,21932,764,8520},
[378]={378,1900,271782,17766,10584,21989,765,8540},
[379]={379,1905,272501,17813,10612,22046,767,8560},
[380]={380,1910,273220,17860,10640,22103,768,8580},
[381]={381,1915,273939,17907,10668,22160,770,8600},
[382]={382,1920,274658,17954,10696,22217,771,8620},
[383]={383,1925,275377,18001,10724,22274,773,8640},
[384]={384,1930,276096,18048,10752,22331,774,8660},
[385]={385,1935,276815,18095,10780,22388,776,8680},
[386]={386,1940,277534,18142,10808,22445,777,8700},
[387]={387,1945,278253,18189,10836,22502,779,8720},
[388]={388,1950,278972,18236,10864,22559,780,8740},
[389]={389,1955,279691,18283,10892,22616,782,8760},
[390]={390,1960,280410,18330,10920,22673,783,8780},
[391]={391,1965,281129,18377,10948,22730,785,8800},
[392]={392,1970,281848,18424,10976,22787,786,8820},
[393]={393,1975,282567,18471,11004,22844,788,8840},
[394]={394,1980,283286,18518,11032,22901,789,8860},
[395]={395,1985,284005,18565,11060,22958,791,8880},
[396]={396,1990,284724,18612,11088,23015,792,8900},
[397]={397,1995,285443,18659,11116,23072,794,8920},
[398]={398,2000,286162,18706,11144,23129,795,8940},
[399]={399,2005,286881,18753,11172,23186,797,8960},
[400]={400,2010,287600,18800,11200,23243,798,8980},
[401]={401,2015,288319,18847,11228,23300,800,9000},
[402]={402,2020,289038,18894,11256,23357,801,9020},
[403]={403,2025,289757,18941,11284,23414,803,9040},
[404]={404,2030,290476,18988,11312,23471,804,9060},
[405]={405,2035,291195,19035,11340,23528,806,9080},
[406]={406,2040,291914,19082,11368,23585,807,9100},
[407]={407,2045,292633,19129,11396,23642,809,9120},
[408]={408,2050,293352,19176,11424,23699,810,9140},
[409]={409,2055,294071,19223,11452,23756,812,9160},
[410]={410,2060,294790,19270,11480,23813,813,9180},
[411]={411,2065,295509,19317,11508,23870,815,9200},
[412]={412,2070,296228,19364,11536,23927,816,9220},
[413]={413,2075,296947,19411,11564,23984,818,9240},
[414]={414,2080,297666,19458,11592,24041,819,9260},
[415]={415,2085,298385,19505,11620,24098,821,9280},
[416]={416,2090,299104,19552,11648,24155,822,9300},
[417]={417,2095,299823,19599,11676,24212,824,9320},
[418]={418,2100,300542,19646,11704,24269,825,9340},
[419]={419,2105,301261,19693,11732,24326,827,9360},
[420]={420,2110,301980,19740,11760,24383,828,9380},
[421]={421,2115,302699,19787,11788,24440,830,9400},
[422]={422,2120,303418,19834,11816,24497,831,9420},
[423]={423,2125,304137,19881,11844,24554,833,9440},
[424]={424,2130,304856,19928,11872,24611,834,9460},
[425]={425,2135,305575,19975,11900,24668,836,9480},
[426]={426,2140,306294,20022,11928,24725,837,9500},
[427]={427,2145,307013,20069,11956,24782,839,9520},
[428]={428,2150,307732,20116,11984,24839,840,9540},
[429]={429,2155,308451,20163,12012,24896,842,9560},
[430]={430,2160,309170,20210,12040,24953,843,9580},
[431]={431,2165,309889,20257,12068,25010,845,9600},
[432]={432,2170,310608,20304,12096,25067,846,9620},
[433]={433,2175,311327,20351,12124,25124,848,9640},
[434]={434,2180,312046,20398,12152,25181,849,9660},
[435]={435,2185,312765,20445,12180,25238,851,9680},
[436]={436,2190,313484,20492,12208,25295,852,9700},
[437]={437,2195,314203,20539,12236,25352,854,9720},
[438]={438,2200,314922,20586,12264,25409,855,9740},
[439]={439,2205,315641,20633,12292,25466,857,9760},
[440]={440,2210,316360,20680,12320,25523,858,9780},
[441]={441,2215,317079,20727,12348,25580,860,9800},
[442]={442,2220,317798,20774,12376,25637,861,9820},
[443]={443,2225,318517,20821,12404,25694,863,9840},
[444]={444,2230,319236,20868,12432,25751,864,9860},
[445]={445,2235,319955,20915,12460,25808,866,9880},
[446]={446,2240,320674,20962,12488,25865,867,9900},
[447]={447,2245,321393,21009,12516,25922,869,9920},
[448]={448,2250,322112,21056,12544,25979,870,9940},
[449]={449,2255,322831,21103,12572,26036,872,9960},
[450]={450,2260,323550,21150,12600,26093,873,9980},
[451]={451,2265,324269,21197,12628,26150,875,10000},
[452]={452,2270,324988,21244,12656,26207,876,10020},
[453]={453,2275,325707,21291,12684,26264,878,10040},
[454]={454,2280,326426,21338,12712,26321,879,10060},
[455]={455,2285,327145,21385,12740,26378,881,10080},
[456]={456,2290,327864,21432,12768,26435,882,10100},
[457]={457,2295,328583,21479,12796,26492,884,10120},
[458]={458,2300,329302,21526,12824,26549,885,10140},
[459]={459,2305,330021,21573,12852,26606,887,10160},
[460]={460,2310,330740,21620,12880,26663,888,10180},
[461]={461,2315,331459,21667,12908,26720,890,10200},
[462]={462,2320,332178,21714,12936,26777,891,10220},
[463]={463,2325,332897,21761,12964,26834,893,10240},
[464]={464,2330,333616,21808,12992,26891,894,10260},
[465]={465,2335,334335,21855,13020,26948,896,10280},
[466]={466,2340,335054,21902,13048,27005,897,10300},
[467]={467,2345,335773,21949,13076,27062,899,10320},
[468]={468,2350,336492,21996,13104,27119,900,10340},
[469]={469,2355,337211,22043,13132,27176,902,10360},
[470]={470,2360,337930,22090,13160,27233,903,10380},
[471]={471,2365,338649,22137,13188,27290,905,10400},
[472]={472,2370,339368,22184,13216,27347,906,10420},
[473]={473,2375,340087,22231,13244,27404,908,10440},
[474]={474,2380,340806,22278,13272,27461,909,10460},
[475]={475,2385,341525,22325,13300,27518,911,10480},
[476]={476,2390,342244,22372,13328,27575,912,10500},
[477]={477,2395,342963,22419,13356,27632,914,10520},
[478]={478,2400,343682,22466,13384,27689,915,10540},
[479]={479,2405,344401,22513,13412,27746,917,10560},
[480]={480,2410,345120,22560,13440,27803,918,10580},
[481]={481,2415,345839,22607,13468,27860,920,10600},
[482]={482,2420,346558,22654,13496,27917,921,10620},
[483]={483,2425,347277,22701,13524,27974,923,10640},
[484]={484,2430,347996,22748,13552,28031,924,10660},
[485]={485,2435,348715,22795,13580,28088,926,10680},
[486]={486,2440,349434,22842,13608,28145,927,10700},
[487]={487,2445,350153,22889,13636,28202,929,10720},
[488]={488,2450,350872,22936,13664,28259,930,10740},
[489]={489,2455,351591,22983,13692,28316,932,10760},
[490]={490,2460,352310,23030,13720,28373,933,10780},
[491]={491,2465,353029,23077,13748,28430,935,10800},
[492]={492,2470,353748,23124,13776,28487,936,10820},
[493]={493,2475,354467,23171,13804,28544,938,10840},
[494]={494,2480,355186,23218,13832,28601,939,10860},
[495]={495,2485,355905,23265,13860,28658,941,10880},
[496]={496,2490,356624,23312,13888,28715,942,10900},
[497]={497,2495,357343,23359,13916,28772,944,10920},
[498]={498,2500,358062,23406,13944,28829,945,10940},
[499]={499,2505,358781,23453,13972,28886,947,10960},
[500]={500,26000,359500,23500,14000,28943,948,10980}
}
local ks={level=1,exp=2,hp_max=3,block=4,phy_att=5,fatal=6,fatal_bonus=7,phy_bld=8}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(graphic_attr)do setmetatable(v,base)end base.__metatable=false
return graphic_attr
