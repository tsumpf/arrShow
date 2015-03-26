function asGlobalValueChanger(asObjs)

if nargin < 1
    global asObjs
end

protect_distance = true;

% generate panel 
fh = gcf;
set(fh,'WindowScrollWheelFcn',@scollWheelCb);
set(fh,'menubar','none');
set(fh,'position',[1025,677,116,92]);

ph = uipanel(fh);
vo = asValueChangerClass(ph,'position',[0 0 1 3],...
    'callback',@mycb,...
    'min',-inf,...
    'max',inf,...
    'colondim1callback',@(varargin)cd1cb,...
    'colondim2callback',@(varargin)cd2cb);

val = str2double(vo.getStr);

    function cd2cb
        protect_distance = false;     
    end
    function cd1cb
        protect_distance = true;        
    end
    
    function mycb(obj)
        newVal = str2double(vo.getStr);
        if newVal > val && ~limitExceeded(1)           
            for i = 1 : length(asObjs)
                asObjs(i).selection.increaseCurrentVc();
            end
            
        elseif newVal < val && ~limitExceeded(-1)
            for i = 1 : length(asObjs)            
                asObjs(i).selection.decreaseCurrentVc();
            end
        end
        val = newVal;
    end

    function bool = limitExceeded(inc)
        bool = false;
        if ~protect_distance
            return
        end
        for i = 1 : length(asObjs)
            currVal = str2double(asObjs(i).selection.getCurrentVcValue(false));
            currVal = currVal + inc;
            vc = asObjs(i).selection.getCurrentVc();
            maxVal = vc.getMax;
            minVal = vc.getMin;
            if currVal > maxVal || currVal < minVal
                bool = true;
                return;
            end
        end
    end

       function scollWheelCb(src,evnt)
            
            switch evnt.VerticalScrollCount
                case -1  %up
                    vo.up();
                case 1  % down
                    vo.down();
            end
        end
end