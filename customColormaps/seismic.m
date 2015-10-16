function c = seismic()
% This is the seismic colormap,
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
   0.0000000e+00   0.0000000e+00   3.0000000e-01
   0.0000000e+00   0.0000000e+00   3.1098039e-01
   0.0000000e+00   0.0000000e+00   3.2196078e-01
   0.0000000e+00   0.0000000e+00   3.3294118e-01
   0.0000000e+00   0.0000000e+00   3.4392157e-01
   0.0000000e+00   0.0000000e+00   3.5490196e-01
   0.0000000e+00   0.0000000e+00   3.6588235e-01
   0.0000000e+00   0.0000000e+00   3.7686275e-01
   0.0000000e+00   0.0000000e+00   3.8784314e-01
   0.0000000e+00   0.0000000e+00   3.9882353e-01
   0.0000000e+00   0.0000000e+00   4.0980392e-01
   0.0000000e+00   0.0000000e+00   4.2078431e-01
   0.0000000e+00   0.0000000e+00   4.3176471e-01
   0.0000000e+00   0.0000000e+00   4.4274510e-01
   0.0000000e+00   0.0000000e+00   4.5372549e-01
   0.0000000e+00   0.0000000e+00   4.6470588e-01
   0.0000000e+00   0.0000000e+00   4.7568627e-01
   0.0000000e+00   0.0000000e+00   4.8666667e-01
   0.0000000e+00   0.0000000e+00   4.9764706e-01
   0.0000000e+00   0.0000000e+00   5.0862745e-01
   0.0000000e+00   0.0000000e+00   5.1960784e-01
   0.0000000e+00   0.0000000e+00   5.3058824e-01
   0.0000000e+00   0.0000000e+00   5.4156863e-01
   0.0000000e+00   0.0000000e+00   5.5254902e-01
   0.0000000e+00   0.0000000e+00   5.6352941e-01
   0.0000000e+00   0.0000000e+00   5.7450980e-01
   0.0000000e+00   0.0000000e+00   5.8549020e-01
   0.0000000e+00   0.0000000e+00   5.9647059e-01
   0.0000000e+00   0.0000000e+00   6.0745098e-01
   0.0000000e+00   0.0000000e+00   6.1843137e-01
   0.0000000e+00   0.0000000e+00   6.2941176e-01
   0.0000000e+00   0.0000000e+00   6.4039216e-01
   0.0000000e+00   0.0000000e+00   6.5137255e-01
   0.0000000e+00   0.0000000e+00   6.6235294e-01
   0.0000000e+00   0.0000000e+00   6.7333333e-01
   0.0000000e+00   0.0000000e+00   6.8431373e-01
   0.0000000e+00   0.0000000e+00   6.9529412e-01
   0.0000000e+00   0.0000000e+00   7.0627451e-01
   0.0000000e+00   0.0000000e+00   7.1725490e-01
   0.0000000e+00   0.0000000e+00   7.2823529e-01
   0.0000000e+00   0.0000000e+00   7.3921569e-01
   0.0000000e+00   0.0000000e+00   7.5019608e-01
   0.0000000e+00   0.0000000e+00   7.6117647e-01
   0.0000000e+00   0.0000000e+00   7.7215686e-01
   0.0000000e+00   0.0000000e+00   7.8313725e-01
   0.0000000e+00   0.0000000e+00   7.9411765e-01
   0.0000000e+00   0.0000000e+00   8.0509804e-01
   0.0000000e+00   0.0000000e+00   8.1607843e-01
   0.0000000e+00   0.0000000e+00   8.2705882e-01
   0.0000000e+00   0.0000000e+00   8.3803922e-01
   0.0000000e+00   0.0000000e+00   8.4901961e-01
   0.0000000e+00   0.0000000e+00   8.6000000e-01
   0.0000000e+00   0.0000000e+00   8.7098039e-01
   0.0000000e+00   0.0000000e+00   8.8196078e-01
   0.0000000e+00   0.0000000e+00   8.9294118e-01
   0.0000000e+00   0.0000000e+00   9.0392157e-01
   0.0000000e+00   0.0000000e+00   9.1490196e-01
   0.0000000e+00   0.0000000e+00   9.2588235e-01
   0.0000000e+00   0.0000000e+00   9.3686275e-01
   0.0000000e+00   0.0000000e+00   9.4784314e-01
   0.0000000e+00   0.0000000e+00   9.5882353e-01
   0.0000000e+00   0.0000000e+00   9.6980392e-01
   0.0000000e+00   0.0000000e+00   9.8078431e-01
   0.0000000e+00   0.0000000e+00   9.9176471e-01
   3.9215686e-03   3.9215686e-03   1.0000000e+00
   1.9607843e-02   1.9607843e-02   1.0000000e+00
   3.5294118e-02   3.5294118e-02   1.0000000e+00
   5.0980392e-02   5.0980392e-02   1.0000000e+00
   6.6666667e-02   6.6666667e-02   1.0000000e+00
   8.2352941e-02   8.2352941e-02   1.0000000e+00
   9.8039216e-02   9.8039216e-02   1.0000000e+00
   1.1372549e-01   1.1372549e-01   1.0000000e+00
   1.2941176e-01   1.2941176e-01   1.0000000e+00
   1.4509804e-01   1.4509804e-01   1.0000000e+00
   1.6078431e-01   1.6078431e-01   1.0000000e+00
   1.7647059e-01   1.7647059e-01   1.0000000e+00
   1.9215686e-01   1.9215686e-01   1.0000000e+00
   2.0784314e-01   2.0784314e-01   1.0000000e+00
   2.2352941e-01   2.2352941e-01   1.0000000e+00
   2.3921569e-01   2.3921569e-01   1.0000000e+00
   2.5490196e-01   2.5490196e-01   1.0000000e+00
   2.7058824e-01   2.7058824e-01   1.0000000e+00
   2.8627451e-01   2.8627451e-01   1.0000000e+00
   3.0196078e-01   3.0196078e-01   1.0000000e+00
   3.1764706e-01   3.1764706e-01   1.0000000e+00
   3.3333333e-01   3.3333333e-01   1.0000000e+00
   3.4901961e-01   3.4901961e-01   1.0000000e+00
   3.6470588e-01   3.6470588e-01   1.0000000e+00
   3.8039216e-01   3.8039216e-01   1.0000000e+00
   3.9607843e-01   3.9607843e-01   1.0000000e+00
   4.1176471e-01   4.1176471e-01   1.0000000e+00
   4.2745098e-01   4.2745098e-01   1.0000000e+00
   4.4313725e-01   4.4313725e-01   1.0000000e+00
   4.5882353e-01   4.5882353e-01   1.0000000e+00
   4.7450980e-01   4.7450980e-01   1.0000000e+00
   4.9019608e-01   4.9019608e-01   1.0000000e+00
   5.0588235e-01   5.0588235e-01   1.0000000e+00
   5.2156863e-01   5.2156863e-01   1.0000000e+00
   5.3725490e-01   5.3725490e-01   1.0000000e+00
   5.5294118e-01   5.5294118e-01   1.0000000e+00
   5.6862745e-01   5.6862745e-01   1.0000000e+00
   5.8431373e-01   5.8431373e-01   1.0000000e+00
   6.0000000e-01   6.0000000e-01   1.0000000e+00
   6.1568627e-01   6.1568627e-01   1.0000000e+00
   6.3137255e-01   6.3137255e-01   1.0000000e+00
   6.4705882e-01   6.4705882e-01   1.0000000e+00
   6.6274510e-01   6.6274510e-01   1.0000000e+00
   6.7843137e-01   6.7843137e-01   1.0000000e+00
   6.9411765e-01   6.9411765e-01   1.0000000e+00
   7.0980392e-01   7.0980392e-01   1.0000000e+00
   7.2549020e-01   7.2549020e-01   1.0000000e+00
   7.4117647e-01   7.4117647e-01   1.0000000e+00
   7.5686275e-01   7.5686275e-01   1.0000000e+00
   7.7254902e-01   7.7254902e-01   1.0000000e+00
   7.8823529e-01   7.8823529e-01   1.0000000e+00
   8.0392157e-01   8.0392157e-01   1.0000000e+00
   8.1960784e-01   8.1960784e-01   1.0000000e+00
   8.3529412e-01   8.3529412e-01   1.0000000e+00
   8.5098039e-01   8.5098039e-01   1.0000000e+00
   8.6666667e-01   8.6666667e-01   1.0000000e+00
   8.8235294e-01   8.8235294e-01   1.0000000e+00
   8.9803922e-01   8.9803922e-01   1.0000000e+00
   9.1372549e-01   9.1372549e-01   1.0000000e+00
   9.2941176e-01   9.2941176e-01   1.0000000e+00
   9.4509804e-01   9.4509804e-01   1.0000000e+00
   9.6078431e-01   9.6078431e-01   1.0000000e+00
   9.7647059e-01   9.7647059e-01   1.0000000e+00
   9.9215686e-01   9.9215686e-01   1.0000000e+00
   1.0000000e+00   9.9215686e-01   9.9215686e-01
   1.0000000e+00   9.7647059e-01   9.7647059e-01
   1.0000000e+00   9.6078431e-01   9.6078431e-01
   1.0000000e+00   9.4509804e-01   9.4509804e-01
   1.0000000e+00   9.2941176e-01   9.2941176e-01
   1.0000000e+00   9.1372549e-01   9.1372549e-01
   1.0000000e+00   8.9803922e-01   8.9803922e-01
   1.0000000e+00   8.8235294e-01   8.8235294e-01
   1.0000000e+00   8.6666667e-01   8.6666667e-01
   1.0000000e+00   8.5098039e-01   8.5098039e-01
   1.0000000e+00   8.3529412e-01   8.3529412e-01
   1.0000000e+00   8.1960784e-01   8.1960784e-01
   1.0000000e+00   8.0392157e-01   8.0392157e-01
   1.0000000e+00   7.8823529e-01   7.8823529e-01
   1.0000000e+00   7.7254902e-01   7.7254902e-01
   1.0000000e+00   7.5686275e-01   7.5686275e-01
   1.0000000e+00   7.4117647e-01   7.4117647e-01
   1.0000000e+00   7.2549020e-01   7.2549020e-01
   1.0000000e+00   7.0980392e-01   7.0980392e-01
   1.0000000e+00   6.9411765e-01   6.9411765e-01
   1.0000000e+00   6.7843137e-01   6.7843137e-01
   1.0000000e+00   6.6274510e-01   6.6274510e-01
   1.0000000e+00   6.4705882e-01   6.4705882e-01
   1.0000000e+00   6.3137255e-01   6.3137255e-01
   1.0000000e+00   6.1568627e-01   6.1568627e-01
   1.0000000e+00   6.0000000e-01   6.0000000e-01
   1.0000000e+00   5.8431373e-01   5.8431373e-01
   1.0000000e+00   5.6862745e-01   5.6862745e-01
   1.0000000e+00   5.5294118e-01   5.5294118e-01
   1.0000000e+00   5.3725490e-01   5.3725490e-01
   1.0000000e+00   5.2156863e-01   5.2156863e-01
   1.0000000e+00   5.0588235e-01   5.0588235e-01
   1.0000000e+00   4.9019608e-01   4.9019608e-01
   1.0000000e+00   4.7450980e-01   4.7450980e-01
   1.0000000e+00   4.5882353e-01   4.5882353e-01
   1.0000000e+00   4.4313725e-01   4.4313725e-01
   1.0000000e+00   4.2745098e-01   4.2745098e-01
   1.0000000e+00   4.1176471e-01   4.1176471e-01
   1.0000000e+00   3.9607843e-01   3.9607843e-01
   1.0000000e+00   3.8039216e-01   3.8039216e-01
   1.0000000e+00   3.6470588e-01   3.6470588e-01
   1.0000000e+00   3.4901961e-01   3.4901961e-01
   1.0000000e+00   3.3333333e-01   3.3333333e-01
   1.0000000e+00   3.1764706e-01   3.1764706e-01
   1.0000000e+00   3.0196078e-01   3.0196078e-01
   1.0000000e+00   2.8627451e-01   2.8627451e-01
   1.0000000e+00   2.7058824e-01   2.7058824e-01
   1.0000000e+00   2.5490196e-01   2.5490196e-01
   1.0000000e+00   2.3921569e-01   2.3921569e-01
   1.0000000e+00   2.2352941e-01   2.2352941e-01
   1.0000000e+00   2.0784314e-01   2.0784314e-01
   1.0000000e+00   1.9215686e-01   1.9215686e-01
   1.0000000e+00   1.7647059e-01   1.7647059e-01
   1.0000000e+00   1.6078431e-01   1.6078431e-01
   1.0000000e+00   1.4509804e-01   1.4509804e-01
   1.0000000e+00   1.2941176e-01   1.2941176e-01
   1.0000000e+00   1.1372549e-01   1.1372549e-01
   1.0000000e+00   9.8039216e-02   9.8039216e-02
   1.0000000e+00   8.2352941e-02   8.2352941e-02
   1.0000000e+00   6.6666667e-02   6.6666667e-02
   1.0000000e+00   5.0980392e-02   5.0980392e-02
   1.0000000e+00   3.5294118e-02   3.5294118e-02
   1.0000000e+00   1.9607843e-02   1.9607843e-02
   1.0000000e+00   3.9215686e-03   3.9215686e-03
   9.9411765e-01   0.0000000e+00   0.0000000e+00
   9.8627451e-01   0.0000000e+00   0.0000000e+00
   9.7843137e-01   0.0000000e+00   0.0000000e+00
   9.7058824e-01   0.0000000e+00   0.0000000e+00
   9.6274510e-01   0.0000000e+00   0.0000000e+00
   9.5490196e-01   0.0000000e+00   0.0000000e+00
   9.4705882e-01   0.0000000e+00   0.0000000e+00
   9.3921569e-01   0.0000000e+00   0.0000000e+00
   9.3137255e-01   0.0000000e+00   0.0000000e+00
   9.2352941e-01   0.0000000e+00   0.0000000e+00
   9.1568627e-01   0.0000000e+00   0.0000000e+00
   9.0784314e-01   0.0000000e+00   0.0000000e+00
   9.0000000e-01   0.0000000e+00   0.0000000e+00
   8.9215686e-01   0.0000000e+00   0.0000000e+00
   8.8431373e-01   0.0000000e+00   0.0000000e+00
   8.7647059e-01   0.0000000e+00   0.0000000e+00
   8.6862745e-01   0.0000000e+00   0.0000000e+00
   8.6078431e-01   0.0000000e+00   0.0000000e+00
   8.5294118e-01   0.0000000e+00   0.0000000e+00
   8.4509804e-01   0.0000000e+00   0.0000000e+00
   8.3725490e-01   0.0000000e+00   0.0000000e+00
   8.2941176e-01   0.0000000e+00   0.0000000e+00
   8.2156863e-01   0.0000000e+00   0.0000000e+00
   8.1372549e-01   0.0000000e+00   0.0000000e+00
   8.0588235e-01   0.0000000e+00   0.0000000e+00
   7.9803922e-01   0.0000000e+00   0.0000000e+00
   7.9019608e-01   0.0000000e+00   0.0000000e+00
   7.8235294e-01   0.0000000e+00   0.0000000e+00
   7.7450980e-01   0.0000000e+00   0.0000000e+00
   7.6666667e-01   0.0000000e+00   0.0000000e+00
   7.5882353e-01   0.0000000e+00   0.0000000e+00
   7.5098039e-01   0.0000000e+00   0.0000000e+00
   7.4313725e-01   0.0000000e+00   0.0000000e+00
   7.3529412e-01   0.0000000e+00   0.0000000e+00
   7.2745098e-01   0.0000000e+00   0.0000000e+00
   7.1960784e-01   0.0000000e+00   0.0000000e+00
   7.1176471e-01   0.0000000e+00   0.0000000e+00
   7.0392157e-01   0.0000000e+00   0.0000000e+00
   6.9607843e-01   0.0000000e+00   0.0000000e+00
   6.8823529e-01   0.0000000e+00   0.0000000e+00
   6.8039216e-01   0.0000000e+00   0.0000000e+00
   6.7254902e-01   0.0000000e+00   0.0000000e+00
   6.6470588e-01   0.0000000e+00   0.0000000e+00
   6.5686275e-01   0.0000000e+00   0.0000000e+00
   6.4901961e-01   0.0000000e+00   0.0000000e+00
   6.4117647e-01   0.0000000e+00   0.0000000e+00
   6.3333333e-01   0.0000000e+00   0.0000000e+00
   6.2549020e-01   0.0000000e+00   0.0000000e+00
   6.1764706e-01   0.0000000e+00   0.0000000e+00
   6.0980392e-01   0.0000000e+00   0.0000000e+00
   6.0196078e-01   0.0000000e+00   0.0000000e+00
   5.9411765e-01   0.0000000e+00   0.0000000e+00
   5.8627451e-01   0.0000000e+00   0.0000000e+00
   5.7843137e-01   0.0000000e+00   0.0000000e+00
   5.7058824e-01   0.0000000e+00   0.0000000e+00
   5.6274510e-01   0.0000000e+00   0.0000000e+00
   5.5490196e-01   0.0000000e+00   0.0000000e+00
   5.4705882e-01   0.0000000e+00   0.0000000e+00
   5.3921569e-01   0.0000000e+00   0.0000000e+00
   5.3137255e-01   0.0000000e+00   0.0000000e+00
   5.2352941e-01   0.0000000e+00   0.0000000e+00
   5.1568627e-01   0.0000000e+00   0.0000000e+00
   5.0784314e-01   0.0000000e+00   0.0000000e+00
   5.0000000e-01   0.0000000e+00   0.0000000e+00];
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
