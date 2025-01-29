function [track_history] = one_to_many_point_correspondence(ts, det_history, track_history,max_age, max_dist, max_del_dirn,points_struct)

indexed_points = track_history{1};

for it = 2:length(ts)
    curr_time = ts(it);
    curr_pos = det_history{it};
    for i_curr = 1:length(curr_pos)
        point = points_struct;
        point.pos = curr_pos(:, i_curr);
        point.update_time = curr_time;

        % correspond to previous points
        best_dist = inf;
        best_prev = points_struct;
        best_i_prev = -1;
        best_time = -inf;

        for i_prev = 1:length(indexed_points)
            prev_point = indexed_points{i_prev};

            if prev_point.update_time == curr_time
                continue
            end

            % distance relative to previous point
            displ = point.pos - prev_point.pos;
            dirn = atan2(displ(2),displ(1));

            if ~isempty(prev_point.displ) && ~isnan(prev_point.del_t) && ~isnan(prev_point.update_time)
                vel_prev = prev_point.displ / prev_point.del_t;
                del_t = point.update_time - prev_point.update_time;
                displ = point.pos - (prev_point.pos + vel_prev*del_t);
            end
            dist = norm(displ);


            dirn_diff = calc_small_angle_diff(dirn, prev_point.dirn);

            eps = 0.1;

            dist_cond = dist < best_dist || (abs(dist - best_dist) <= eps && best_time < prev_point.update_time);
            %             dist_cond = dist < best_dist;

            if isnan(dirn_diff)
                is_match = dist < max_dist && dist_cond;
            else
                is_match = dist < max_dist && dist_cond && abs(dirn_diff) < max_del_dirn;
            end

            if is_match
                best_dist = dist;
                best_prev = prev_point;
                best_i_prev = i_prev;
                best_time = prev_point.update_time;
            end

        end

        % update point based on closest matching point
        if best_dist < inf
            point.prev = best_prev;
            point.depth = best_prev.depth + 1;
            point.displ = point.pos - best_prev.pos;
            point.dirn = atan2(point.displ(2),point.displ(1));
            point.del_dirn = calc_small_angle_diff(point.dirn, best_prev.dirn);
            point.del_t = point.update_time - best_prev.update_time;
        end

        indexed_points{end+1} = point;
    end

    % remove old elements
    remove_idx = [];
    for j = 1:length(indexed_points)
        if curr_time - indexed_points{j}.update_time > max_age
            remove_idx = [remove_idx j];
        end
    end
    indexed_points(remove_idx) = [];

    track_history{it} = indexed_points;
end
end