function c = rdbu_r()
% This is the RdBu_r ("Red Blue diverging, reversed") colormap,
% exported from matplotlib
% (http://matplotlib.org) using this scrpt:

%   #!/usr/bin/env python3
%   
%   from matplotlib import cm
%   import os.path
%   import sys
%   import scipy.io
%   import numpy as np
%   
%   
%   try:
%       cmapname = sys.argv[1]
%       cmap = getattr(cm, cmapname)
%   except:
%       sys.exit(1)
%   
%   vals = np.array([cmap(i) for i in range(0,256)])[:, 0:3]
%   
%   scipy.io.savemat(cmapname + '.mat', {cmapname: vals})

% matplotlib is distributed under a custom license, available here
% (http://matplotlib.org/1.4.0/users/license.html) or quoted at the end of
% this file. matplotlib in general and this colormap in particular are
% “Copyright (c) 2012-2013 Matplotlib Development Team; All Rights Reserved”



persistent cmap
if isempty(cmap)
	cmap = [...
		   1.9607844e-02   1.8823530e-01   3.8039216e-01
   2.3913880e-02   1.9653980e-01   3.9192619e-01
   2.8219917e-02   2.0484429e-01   4.0346022e-01
   3.2525953e-02   2.1314879e-01   4.1499424e-01
   3.6831989e-02   2.2145329e-01   4.2652827e-01
   4.1138026e-02   2.2975779e-01   4.3806229e-01
   4.5444062e-02   2.3806229e-01   4.4959632e-01
   4.9750099e-02   2.4636679e-01   4.6113034e-01
   5.4056135e-02   2.5467128e-01   4.7266437e-01
   5.8362171e-02   2.6297578e-01   4.8419840e-01
   6.2668208e-02   2.7128028e-01   4.9573242e-01
   6.6974244e-02   2.7958478e-01   5.0726645e-01
   7.1280281e-02   2.8788928e-01   5.1880047e-01
   7.5586317e-02   2.9619378e-01   5.3033450e-01
   7.9892353e-02   3.0449827e-01   5.4186853e-01
   8.4198390e-02   3.1280277e-01   5.5340255e-01
   8.8504426e-02   3.2110727e-01   5.6493658e-01
   9.2810463e-02   3.2941177e-01   5.7647060e-01
   9.7116499e-02   3.3771627e-01   5.8800463e-01
   1.0142254e-01   3.4602077e-01   5.9953866e-01
   1.0572857e-01   3.5432526e-01   6.1107268e-01
   1.1003461e-01   3.6262976e-01   6.2260671e-01
   1.1434064e-01   3.7093426e-01   6.3414073e-01
   1.1864668e-01   3.7923876e-01   6.4567476e-01
   1.2295272e-01   3.8754326e-01   6.5720878e-01
   1.2725875e-01   3.9584776e-01   6.6874281e-01
   1.3202615e-01   4.0346021e-01   6.7627837e-01
   1.3725491e-01   4.1038063e-01   6.7981547e-01
   1.4248367e-01   4.1730105e-01   6.8335258e-01
   1.4771243e-01   4.2422146e-01   6.8688968e-01
   1.5294118e-01   4.3114188e-01   6.9042678e-01
   1.5816994e-01   4.3806229e-01   6.9396388e-01
   1.6339870e-01   4.4498271e-01   6.9750098e-01
   1.6862746e-01   4.5190313e-01   7.0103808e-01
   1.7385622e-01   4.5882354e-01   7.0457518e-01
   1.7908498e-01   4.6574396e-01   7.0811228e-01
   1.8431374e-01   4.7266437e-01   7.1164938e-01
   1.8954249e-01   4.7958479e-01   7.1518648e-01
   1.9477125e-01   4.8650521e-01   7.1872358e-01
   2.0000001e-01   4.9342562e-01   7.2226069e-01
   2.0522877e-01   5.0034604e-01   7.2579779e-01
   2.1045753e-01   5.0726645e-01   7.2933489e-01
   2.1568629e-01   5.1418687e-01   7.3287199e-01
   2.2091504e-01   5.2110729e-01   7.3640909e-01
   2.2614380e-01   5.2802770e-01   7.3994619e-01
   2.3137256e-01   5.3494812e-01   7.4348329e-01
   2.3660132e-01   5.4186853e-01   7.4702039e-01
   2.4183008e-01   5.4878895e-01   7.5055749e-01
   2.4705884e-01   5.5570937e-01   7.5409459e-01
   2.5228760e-01   5.6262978e-01   7.5763169e-01
   2.5751635e-01   5.6955020e-01   7.6116880e-01
   2.6274511e-01   5.7647061e-01   7.6470590e-01
   2.7489429e-01   5.8415996e-01   7.6885815e-01
   2.8704346e-01   5.9184931e-01   7.7301039e-01
   2.9919263e-01   5.9953866e-01   7.7716264e-01
   3.1134181e-01   6.0722801e-01   7.8131489e-01
   3.2349098e-01   6.1491736e-01   7.8546714e-01
   3.3564016e-01   6.2260671e-01   7.8961939e-01
   3.4778933e-01   6.3029606e-01   7.9377164e-01
   3.5993850e-01   6.3798541e-01   7.9792389e-01
   3.7208768e-01   6.4567476e-01   8.0207614e-01
   3.8423685e-01   6.5336411e-01   8.0622839e-01
   3.9638602e-01   6.6105346e-01   8.1038063e-01
   4.0853520e-01   6.6874281e-01   8.1453288e-01
   4.2068437e-01   6.7643216e-01   8.1868513e-01
   4.3283355e-01   6.8412151e-01   8.2283738e-01
   4.4498272e-01   6.9181086e-01   8.2698963e-01
   4.5713189e-01   6.9950021e-01   8.3114188e-01
   4.6928107e-01   7.0718956e-01   8.3529413e-01
   4.8143024e-01   7.1487891e-01   8.3944638e-01
   4.9357942e-01   7.2256826e-01   8.4359863e-01
   5.0572859e-01   7.3025761e-01   8.4775087e-01
   5.1787776e-01   7.3794696e-01   8.5190312e-01
   5.3002694e-01   7.4563631e-01   8.5605537e-01
   5.4217611e-01   7.5332566e-01   8.6020762e-01
   5.5432528e-01   7.6101501e-01   8.6435987e-01
   5.6647446e-01   7.6870436e-01   8.6851212e-01
   5.7739334e-01   7.7500963e-01   8.7197233e-01
   5.8708192e-01   7.7993081e-01   8.7474049e-01
   5.9677050e-01   7.8485199e-01   8.7750866e-01
   6.0645908e-01   7.8977318e-01   8.8027682e-01
   6.1614766e-01   7.9469436e-01   8.8304499e-01
   6.2583624e-01   7.9961554e-01   8.8581316e-01
   6.3552482e-01   8.0453673e-01   8.8858132e-01
   6.4521340e-01   8.0945791e-01   8.9134949e-01
   6.5490198e-01   8.1437910e-01   8.9411765e-01
   6.6459056e-01   8.1930028e-01   8.9688582e-01
   6.7427914e-01   8.2422146e-01   8.9965399e-01
   6.8396772e-01   8.2914265e-01   9.0242215e-01
   6.9365630e-01   8.3406383e-01   9.0519032e-01
   7.0334489e-01   8.3898502e-01   9.0795848e-01
   7.1303347e-01   8.4390620e-01   9.1072665e-01
   7.2272205e-01   8.4882738e-01   9.1349481e-01
   7.3241063e-01   8.5374857e-01   9.1626298e-01
   7.4209921e-01   8.5866975e-01   9.1903115e-01
   7.5178779e-01   8.6359093e-01   9.2179931e-01
   7.6147637e-01   8.6851212e-01   9.2456748e-01
   7.7116495e-01   8.7343330e-01   9.2733564e-01
   7.8085353e-01   8.7835449e-01   9.3010381e-01
   7.9054211e-01   8.8327567e-01   9.3287198e-01
   8.0023069e-01   8.8819685e-01   9.3564014e-01
   8.0991927e-01   8.9311804e-01   9.3840831e-01
   8.1960785e-01   8.9803922e-01   9.4117647e-01
   8.2545176e-01   9.0080739e-01   9.4225298e-01
   8.3129567e-01   9.0357555e-01   9.4332949e-01
   8.3713957e-01   9.0634372e-01   9.4440600e-01
   8.4298348e-01   9.0911189e-01   9.4548251e-01
   8.4882738e-01   9.1188005e-01   9.4655902e-01
   8.5467129e-01   9.1464822e-01   9.4763553e-01
   8.6051519e-01   9.1741638e-01   9.4871204e-01
   8.6635910e-01   9.2018455e-01   9.4978855e-01
   8.7220301e-01   9.2295272e-01   9.5086505e-01
   8.7804691e-01   9.2572088e-01   9.5194156e-01
   8.8389082e-01   9.2848905e-01   9.5301807e-01
   8.8973472e-01   9.3125721e-01   9.5409458e-01
   8.9557863e-01   9.3402538e-01   9.5517109e-01
   9.0142254e-01   9.3679354e-01   9.5624760e-01
   9.0726644e-01   9.3956171e-01   9.5732411e-01
   9.1311035e-01   9.4232988e-01   9.5840062e-01
   9.1895425e-01   9.4509804e-01   9.5947713e-01
   9.2479816e-01   9.4786621e-01   9.6055364e-01
   9.3064206e-01   9.5063437e-01   9.6163014e-01
   9.3648597e-01   9.5340254e-01   9.6270665e-01
   9.4232988e-01   9.5617071e-01   9.6378316e-01
   9.4817378e-01   9.5893887e-01   9.6485967e-01
   9.5401769e-01   9.6170704e-01   9.6593618e-01
   9.5986159e-01   9.6447520e-01   9.6701269e-01
   9.6570550e-01   9.6724337e-01   9.6808920e-01
   9.6908881e-01   9.6647443e-01   9.6493656e-01
   9.7001154e-01   9.6216840e-01   9.5755479e-01
   9.7093426e-01   9.5786236e-01   9.5017301e-01
   9.7185698e-01   9.5355633e-01   9.4279124e-01
   9.7277970e-01   9.4925029e-01   9.3540946e-01
   9.7370242e-01   9.4494426e-01   9.2802769e-01
   9.7462515e-01   9.4063822e-01   9.2064591e-01
   9.7554787e-01   9.3633218e-01   9.1326413e-01
   9.7647059e-01   9.3202615e-01   9.0588236e-01
   9.7739331e-01   9.2772011e-01   8.9850058e-01
   9.7831603e-01   9.2341408e-01   8.9111881e-01
   9.7923876e-01   9.1910804e-01   8.8373703e-01
   9.8016148e-01   9.1480200e-01   8.7635526e-01
   9.8108420e-01   9.1049597e-01   8.6897348e-01
   9.8200692e-01   9.0618993e-01   8.6159170e-01
   9.8292964e-01   9.0188390e-01   8.5420993e-01
   9.8385237e-01   8.9757786e-01   8.4682815e-01
   9.8477509e-01   8.9327182e-01   8.3944638e-01
   9.8569781e-01   8.8896579e-01   8.3206460e-01
   9.8662053e-01   8.8465975e-01   8.2468282e-01
   9.8754325e-01   8.8035372e-01   8.1730105e-01
   9.8846598e-01   8.7604768e-01   8.0991927e-01
   9.8938870e-01   8.7174165e-01   8.0253750e-01
   9.9031142e-01   8.6743561e-01   7.9515572e-01
   9.9123414e-01   8.6312957e-01   7.8777395e-01
   9.9215686e-01   8.5882354e-01   7.8039217e-01
   9.9077278e-01   8.5051904e-01   7.6978087e-01
   9.8938870e-01   8.4221454e-01   7.5916956e-01
   9.8800461e-01   8.3391004e-01   7.4855826e-01
   9.8662053e-01   8.2560555e-01   7.3794696e-01
   9.8523645e-01   8.1730105e-01   7.2733566e-01
   9.8385237e-01   8.0899655e-01   7.1672435e-01
   9.8246828e-01   8.0069205e-01   7.0611305e-01
   9.8108420e-01   7.9238756e-01   6.9550175e-01
   9.7970012e-01   7.8408306e-01   6.8489045e-01
   9.7831603e-01   7.7577856e-01   6.7427914e-01
   9.7693195e-01   7.6747406e-01   6.6366784e-01
   9.7554787e-01   7.5916956e-01   6.5305654e-01
   9.7416378e-01   7.5086507e-01   6.4244523e-01
   9.7277970e-01   7.4256057e-01   6.3183393e-01
   9.7139562e-01   7.3425607e-01   6.2122263e-01
   9.7001154e-01   7.2595157e-01   6.1061133e-01
   9.6862745e-01   7.1764708e-01   6.0000002e-01
   9.6724337e-01   7.0934258e-01   5.8938872e-01
   9.6585929e-01   7.0103808e-01   5.7877742e-01
   9.6447520e-01   6.9273358e-01   5.6816612e-01
   9.6309112e-01   6.8442908e-01   5.5755481e-01
   9.6170704e-01   6.7612459e-01   5.4694351e-01
   9.6032296e-01   6.6782009e-01   5.3633221e-01
   9.5893887e-01   6.5951559e-01   5.2572090e-01
   9.5755479e-01   6.5121109e-01   5.1510960e-01
   9.5455594e-01   6.4175319e-01   5.0572859e-01
   9.4994233e-01   6.3114189e-01   4.9757788e-01
   9.4532872e-01   6.2053058e-01   4.8942717e-01
   9.4071511e-01   6.0991928e-01   4.8127646e-01
   9.3610150e-01   5.9930798e-01   4.7312575e-01
   9.3148789e-01   5.8869667e-01   4.6497504e-01
   9.2687428e-01   5.7808537e-01   4.5682432e-01
   9.2226067e-01   5.6747407e-01   4.4867361e-01
   9.1764706e-01   5.5686276e-01   4.4052290e-01
   9.1303345e-01   5.4625146e-01   4.3237219e-01
   9.0841984e-01   5.3564015e-01   4.2422148e-01
   9.0380623e-01   5.2502885e-01   4.1607076e-01
   8.9919262e-01   5.1441755e-01   4.0792005e-01
   8.9457901e-01   5.0380624e-01   3.9976934e-01
   8.8996540e-01   4.9319494e-01   3.9161863e-01
   8.8535179e-01   4.8258363e-01   3.8346792e-01
   8.8073818e-01   4.7197233e-01   3.7531720e-01
   8.7612457e-01   4.6136103e-01   3.6716649e-01
   8.7151096e-01   4.5074972e-01   3.5901578e-01
   8.6689736e-01   4.4013842e-01   3.5086507e-01
   8.6228375e-01   4.2952712e-01   3.4271436e-01
   8.5767014e-01   4.1891581e-01   3.3456364e-01
   8.5305653e-01   4.0830451e-01   3.2641293e-01
   8.4844292e-01   3.9769320e-01   3.1826222e-01
   8.4382931e-01   3.8708190e-01   3.1011151e-01
   8.3921570e-01   3.7647060e-01   3.0196080e-01
   8.3367936e-01   3.6539793e-01   2.9673204e-01
   8.2814303e-01   3.5432527e-01   2.9150328e-01
   8.2260670e-01   3.4325260e-01   2.8627452e-01
   8.1707037e-01   3.3217994e-01   2.8104576e-01
   8.1153404e-01   3.2110727e-01   2.7581700e-01
   8.0599770e-01   3.1003461e-01   2.7058825e-01
   8.0046137e-01   2.9896194e-01   2.6535949e-01
   7.9492504e-01   2.8788928e-01   2.6013073e-01
   7.8938871e-01   2.7681661e-01   2.5490197e-01
   7.8385238e-01   2.6574395e-01   2.4967321e-01
   7.7831605e-01   2.5467129e-01   2.4444445e-01
   7.7277971e-01   2.4359862e-01   2.3921569e-01
   7.6724338e-01   2.3252596e-01   2.3398694e-01
   7.6170705e-01   2.2145329e-01   2.2875818e-01
   7.5617072e-01   2.1038063e-01   2.2352942e-01
   7.5063439e-01   1.9930796e-01   2.1830066e-01
   7.4509805e-01   1.8823530e-01   2.1307190e-01
   7.3956172e-01   1.7716263e-01   2.0784314e-01
   7.3402539e-01   1.6608997e-01   2.0261439e-01
   7.2848906e-01   1.5501730e-01   1.9738563e-01
   7.2295273e-01   1.4394464e-01   1.9215687e-01
   7.1741640e-01   1.3287197e-01   1.8692811e-01
   7.1188006e-01   1.2179931e-01   1.8169935e-01
   7.0634373e-01   1.1072665e-01   1.7647059e-01
   7.0080740e-01   9.9653981e-02   1.7124184e-01
   6.9227222e-01   9.2272205e-02   1.6770473e-01
   6.8073819e-01   8.8581317e-02   1.6585929e-01
   6.6920417e-01   8.4890428e-02   1.6401385e-01
   6.5767014e-01   8.1199540e-02   1.6216840e-01
   6.4613612e-01   7.7508652e-02   1.6032296e-01
   6.3460209e-01   7.3817764e-02   1.5847751e-01
   6.2306807e-01   7.0126876e-02   1.5663207e-01
   6.1153404e-01   6.6435987e-02   1.5478662e-01
   6.0000001e-01   6.2745099e-02   1.5294118e-01
   5.8846599e-01   5.9054211e-02   1.5109574e-01
   5.7693196e-01   5.5363323e-02   1.4925029e-01
   5.6539794e-01   5.1672435e-02   1.4740485e-01
   5.5386391e-01   4.7981546e-02   1.4555940e-01
   5.4232988e-01   4.4290658e-02   1.4371396e-01
   5.3079586e-01   4.0599770e-02   1.4186851e-01
   5.1926183e-01   3.6908882e-02   1.4002307e-01
   5.0772781e-01   3.3217994e-02   1.3817763e-01
   4.9619378e-01   2.9527106e-02   1.3633218e-01
   4.8465976e-01   2.5836217e-02   1.3448674e-01
   4.7312573e-01   2.2145329e-02   1.3264129e-01
   4.6159170e-01   1.8454441e-02   1.3079585e-01
   4.5005768e-01   1.4763553e-02   1.2895040e-01
   4.3852365e-01   1.1072665e-02   1.2710496e-01
   4.2698963e-01   7.3817764e-03   1.2525952e-01
   4.1545560e-01   3.6908882e-03   1.2341407e-01
   4.0392157e-01   0.0000000e+00   1.2156863e-01];
end
c = cmap;
end

% Harcopy of the matplotlib license in case the website quoted above changes:
% License

%Matplotlib only uses BSD compatible code, and its license is based on the PSF license. 
%See the Open Source Initiative licenses page for details on individual licenses. 
%Non-BSD compatible licenses (eg LGPL) are acceptable in matplotlib toolkits. 
%For a discussion of the motivations behind the licencing choice, see Licenses.
%Copyright Policy
%
%John Hunter began matplotlib around 2003. Since shortly before his passing in 2012, 
%Michael Droettboom has been the lead maintainer of matplotlib, but, as has 
%always been the case, matplotlib is the work of many.
%
%Prior to July of 2013, and the 1.3.0 release, the copyright of the source code 
%was held by John Hunter. As of July 2013, and the 1.3.0 release, matplotlib 
%has moved to a shared copyright model.
%
%matplotlib uses a shared copyright model. Each contributor maintains copyright 
%over their contributions to matplotlib. But, it is important to note that 
%these contributions are typically only changes to the repositories. Thus, 
%the matplotlib source code, in its entirety, is not the copyright of any 
%single person or institution. Instead, it is the collective copyright of 
%the entire matplotlib Development Team. If individual contributors want 
%to maintain a record of what changes/contributions they have specific 
%copyright on, they should indicate their copyright in the commit message 
%of the change, when they commit the change to one of the matplotlib repositories.
%
%The Matplotlib Development Team is the set of all contributors to the 
%matplotlib project. A full list can be obtained from the git version 
%control logs.
%License agreement for matplotlib 1.4.0
%
%1. This LICENSE AGREEMENT is between the Matplotlib Development Team (“MDT”), 
%and the Individual or Organization (“Licensee”) accessing and otherwise 
%using matplotlib software in source or binary form and its associated documentation.
%
%2. Subject to the terms and conditions of this License Agreement, MDT hereby 
%grants Licensee a nonexclusive, royalty-free, world-wide license to reproduce, 
%analyze, test, perform and/or display publicly, prepare derivative works, 
%distribute, and otherwise use matplotlib 1.4.0 alone or in any derivative version, 
%provided, however, that MDT’s License Agreement and MDT’s notice of copyright, 
%i.e., “Copyright (c) 2012-2013 Matplotlib Development Team; All Rights Reserved” 
%are retained in matplotlib 1.4.0 alone or in any derivative version prepared by Licensee.
%
%3. In the event Licensee prepares a derivative work that is based on or incorporates 
%matplotlib 1.4.0 or any part thereof, and wants to make the derivative work available 
%to others as provided herein, then Licensee hereby agrees to include in any such work 
%a brief summary of the changes made to matplotlib 1.4.0.
%
%4. MDT is making matplotlib 1.4.0 available to Licensee on an “AS IS” basis. 
%MDT MAKES NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. BY WAY OF EXAMPLE, 
%BUT NOT LIMITATION, MDT MAKES NO AND DISCLAIMS ANY REPRESENTATION OR WARRANTY OF 
%MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF 
%MATPLOTLIB 1.4.0 WILL NOT INFRINGE ANY THIRD PARTY RIGHTS.
%
%5. MDT SHALL NOT BE LIABLE TO LICENSEE OR ANY OTHER USERS OF MATPLOTLIB 1.4.0 FOR 
%ANY INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES OR LOSS AS A RESULT OF MODIFYING, 
%DISTRIBUTING, OR OTHERWISE USING MATPLOTLIB 1.4.0, OR ANY DERIVATIVE THEREOF, 
%EVEN IF ADVISED OF THE POSSIBILITY THEREOF.
%
%6. This License Agreement will automatically terminate upon a material breach of 
%its terms and conditions.
%
%7. Nothing in this License Agreement shall be deemed to create any relationship 
%of agency, partnership, or joint venture between MDT and Licensee. This 
%License Agreement does not grant permission to use MDT trademarks or trade name 
%in a trademark sense to endorse or promote products or services of Licensee, 
%or any third party.
%
%8. By copying, installing or otherwise using matplotlib 1.4.0, Licensee agrees 
%to be bound by the terms and conditions of this License Agreement.
