
MoZunConfig =
{
    openDay = 1,
    level = {0,70},
    sceneId = 74,
    MoZunTime = 1800,
    enterRange =
    {
    {x = 20, y = 69},	{x = 31, y = 72},	{x = 47, y = 72},	{x = 58, y = 65},
		{x = 56, y = 46},	{x = 52, y = 34},	{x = 44, y = 25},	{x = 34, y = 24},
		{x = 22, y = 21},	{x = 20, y = 35},	{x = 20, y = 49},	{x = 16, y = 61},
		{x = 29, y = 50},	{x = 36, y = 56},	{x = 44, y = 49},	{x = 36, y = 49},
    },
    leavePos = {sceneId = 4, x = 49, y = 71, rang = 3},
    randomEnergy = {timer = 150, allenergy = 100 , oneenergy = 1000},
    killEnergy  = {300,50},
    MoShen =
    {
        {
            buffId = {
              { 635, 653, 680, 707, 734, 743, 754, 763, 772, 781, },
              { 635, 662, 689, 716, 734, 743, 754, 763, 772, 781, },
              { 635, 671, 698, 725, 734, 743, 754, 763, 790, 799, },
            },
            energy = 0,
            killEnergyRate = 0.2,
        },
        {
            buffId = {
              { 636, 654, 681, 708, 735, 744, 755, 764, 773, 782, },
              { 636, 663, 690, 717, 735, 744, 755, 764, 773, 782, },
              { 636, 672, 699, 726, 735, 744, 755, 764, 791, 800, },
            },
            energy = 300,
            killEnergyRate = 0.2,
        },
        {
            buffId = {
              { 637, 655, 682, 709, 736, 745, 756, 765, 774, 783, },
              { 637, 664, 691, 718, 736, 745, 756, 765, 774, 783, },
              { 637, 673, 700, 727, 736, 745, 756, 765, 792, 801, },
            },
            energy = 900,
            killEnergyRate = 0.2,
        },
        {
            buffId = {
              { 638, 656, 683, 710, 737, 746, 757, 766, 775, 784, },
              { 638, 665, 692, 719, 737, 746, 757, 766, 775, 784, },
              { 638, 674, 701, 728, 737, 746, 757, 766, 793, 802, },
            },
            energy = 1800,
            killEnergyRate = 0.25,
        },
        {
            buffId = {
              { 639, 657, 684, 711, 738, 747, 758, 767, 776, 785, },
              { 639, 666, 693, 720, 738, 747, 758, 767, 776, 785, },
              { 639, 675, 702, 729, 738, 747, 758, 767, 794, 803, },
            },
            energy = 3000,
            killEnergyRate = 0.25,
        },
        {
            buffId = {
              { 640, 658, 685, 712, 739, 748, 759, 768, 777, 786, },
              { 640, 667, 694, 721, 739, 748, 759, 768, 777, 786, },
              { 640, 676, 703, 730, 739, 748, 759, 768, 795, 804, },
            },
            energy = 4500,
            killEnergyRate = 0.25,
        },
        {
            buffId = {
              { 641, 659, 686, 713, 740, 749, 760, 769, 778, 787, },
              { 641, 668, 695, 722, 740, 749, 760, 769, 778, 787, },
              { 641, 677, 704, 731, 740, 749, 760, 769, 796, 805, },
            },
           energy = 7000,
            killEnergyRate = 0.3,
        },
        {
            buffId = {
              { 642, 660, 687, 714, 741, 750, 761, 770, 779, 788, },
              { 642, 669, 696, 723, 741, 750, 761, 770, 779, 788, },
              { 642, 678, 705, 732, 741, 750, 761, 770, 797, 806, },
            },
            energy = 10000,
            killEnergyRate = 0.3,
        },
        {
            buffId = {
              { 643, 661, 688, 715, 742, 751, 762, 771, 780, 789, },
              { 643, 670, 697, 724, 742, 751, 762, 771, 780, 789, },
              { 643, 679, 706, 733, 742, 751, 762, 771, 798, 807, },
            },
            energy = 15000,
            killEnergyRate = 0.3,
        },
    },
    Monsters =
    {
        small =
        {
      { monid = 792, energy = 20},
			{ monid = 793, energy = 100},
			{ monid = 789, energy = 100},
			{ monid = 790, energy = 2000},
        },
        bigTimer = {700,900,1100,1300,1500,1700},
        big =
        {
            { monid = 794, count = 1, x1 = 21, x2 = 30, y1 = 45, y2 = 54,livetime = 1800,energy = 1000},
            { monid = 794, count = 1, x1 = 33, x2 = 39, y1 = 59, y2 = 69,livetime = 1800,energy = 1000},
            { monid = 794, count = 1, x1 = 35, x2 = 49, y1 = 29, y2 = 39,livetime = 1800,energy = 1000},
            { monid = 794, count = 1, x1 = 42, x2 = 52, y1 = 47, y2 = 53,livetime = 1800,energy = 1000},
        },
        largeTimer = {1000,1240,1480,1720},
        large =
        {
            { monid = 795, count = 1, x1 = 32, x2 = 38, y1 = 44, y2 = 56,livetime = 1800,energy = 5000},
        },
    },
      RandomMonsterId = {778,791},
      RandomNum = 270,
      RandomEvent =
      {
          {buffId = { 644, },	rate =  5,	msg = Lang.ScriptTips.MoZun004},
          {buffId = { 645, },	rate =  30,	msg = Lang.ScriptTips.MoZun006},
          {buffId = { 647,648,649,650,651,652 },	rate =  100,	msg = Lang.ScriptTips.MoZun005},
          {rate = 100,	monsters = { monid = 789, count = 10, range = 4, livetime = 1800,},	msg = Lang.ScriptTips.MoZun008},
          {rate = 30,	monsters = { monid = 790, count = 1, range = 4, livetime = 1800,},	msg = Lang.ScriptTips.MoZun008},
          {buffId = { 646 },	rate =  5,	msg = Lang.ScriptTips.MoZun007},
      },
      energyMin = 200,
      RankMax = 200,
      RankAwards =
      {
          {
              rankMin = 1, rankMax = 1,
              awards =
              {
                  { type = 11, id = 1, count = 20000, bind = 1 , strong = 0 , quality = 0},
					        { type = 0, id = 4091, count = 30, bind = 1 , strong = 0 , quality = 0},
              },
          },
          {
              rankMin = 2, rankMax = 5,
              awards =
              {
                      { type = 11, id = 1, count = 18000, bind = 1 , strong = 0 , quality = 0},
                      { type = 0, id = 4091, count = 25, bind = 1 , strong = 0 , quality = 0},
              },
          },
          {
              rankMin = 6, rankMax = 20,
              awards =
              {
                      { type = 11, id = 1, count = 15000, bind = 1 , strong = 0 , quality = 0},
                      { type = 0, id = 4091, count = 21, bind = 1 , strong = 0 , quality = 0},
              },
          },
          {
              rankMin = 21, rankMax = 50,
              awards =
              {
                      { type = 11, id = 1, count = 12000, bind = 1 , strong = 0 , quality = 0},
                      { type = 0, id = 4091, count = 18, bind = 1 , strong = 0 , quality = 0},
              },
          },
          {
              rankMin = 51, rankMax = 200,
              awards =
              {
                      { type = 11, id = 1, count = 10000, bind = 1 , strong = 0 , quality = 0},
                      { type = 0, id = 4091, count = 15, bind = 1 , strong = 0 , quality = 0},
              },
          },
      },
      drops =
      {
      },
}
