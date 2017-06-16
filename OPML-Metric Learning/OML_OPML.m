function [ L, Triplet_num,aver_time] = OML_OPML(data, label, lambda)
%% Maintain n queues, where n equals to the number of classes.
% In the binary classification, n is 2.  Here we just utilize cell array as the queues in matlab .

L_pre =eye(size(data,2)); % initialization
latest = data(1,:);
latest_label = label(1); % store the laest data and the corresponding label
queue_array{1} = data(1,:);
queue_label  = label(1);
class_num=1;
Triplet_num=0;
aver_time=0;
for ii=2:size(data,1)
    x_cur = data(ii,:);
    y_cur = label(ii);
    idx=find(queue_label==y_cur);
    flag=isempty(idx);
    
    if class_num>=2 && ~flag
        
        if latest_label==y_cur
            x_p = latest;
            if idx==class_num
                x_q = queue_array{class_num-1};
            else
                x_q = queue_array{class_num};
            end
        else
            x_q = latest;
            x_p = queue_array{idx};
        end
        Triplet_num=Triplet_num+1;
        %%  core algorithm
        tic
        temp1=L_pre*x_cur';
        temp2=L_pre*x_p';
        temp3=L_pre*x_q';
        z = norm(temp1-temp2, 2)^2+1-norm(temp1-temp3, 2)^2;
        if z<=0
            L_cur  = L_pre;
        else
            L_cur  = OML_Core(L_pre, lambda, x_cur', x_p', x_q');
            indic=1;
        end
        L_pre = L_cur;
        t2=toc;
        aver_time=aver_time+t2;
    end
    
    % update the queue
    if flag
        class_num=class_num+1;
        queue_array{class_num} = x_cur;
        queue_label=[queue_label; y_cur];
    else
        queue_array{idx}=x_cur;
    end
    latest = x_cur;
    latest_label = y_cur;
end
L=L_pre;
aver_time=aver_time/size(data,1);
end

