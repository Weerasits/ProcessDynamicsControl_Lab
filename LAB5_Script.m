%% LAB: FAN + Control Valve + TANK (Dynamic) -> เติมตารางจาก Simulink
% Fan:         fi = 0.16*mi
% ControlValve:fo = 0.00506*mo*sqrt( P*(P - P1) )
% Tank:        rho*fi - rho*fo = (V/(R*T)) * dP/dt
% => dP/dt = (R*T/V) * rho * (fi - fo)

clear; clc;

% ค่าคงที่จากรูป
mo   = 50;        % mo_steadyState (%)
P1   = 14.7;      % P_atm (psi)
V    = 20;        % (ตามรูป)
R    = 10.731;    % (ตามรูป)
T    = 520;       % (ตามรูป)
rho  = 0.00263;   % (ตามรูป)
Kv   = 0.00506;   % ค่าหน้า m_o ในสมการวาล์ว
Kfan = 0.16;      % fi = 0.16 mi

% ชุดค่า mi ตามตาราง
mi_vec = (25:5:75).';

% ตั้งค่าการหา steady-state (ใกล้เคียง dP/dt ~ 0)
tEnd = 300;                 % ถ้ายังไม่คงที่ให้เพิ่มได้
dPdt_tol = 1e-6;            % เกณฑ์ว่าเข้าใกล้ steady-state แล้ว (psi/s)
tHold = 5;                  % ต้องต่ำกว่า tol ต่อเนื่องกี่วินาที

% เตรียมเก็บผล
P_ss = nan(size(mi_vec));

% ค่าเริ่มต้นความดัน (ให้เหมือนเริ่มจากความดันบรรยากาศ)
P0 = P1;

for k = 1:numel(mi_vec)
    mi = mi_vec(k);
    fi = Kfan * mi;

    % ODE: dP/dt
    odefun = @(t,P) tank_dPdt(P, fi, mo, P1, V, R, T, rho, Kv);

    % ใช้ ode45 วิ่งจน tEnd
    opts = odeset('RelTol',1e-8,'AbsTol',1e-10);
    [tt, PP] = ode45(odefun, [0 tEnd], P0, opts);

    % หาค่า steady-state แบบตรวจ dP/dt ช่วงท้าย
    dPdt = arrayfun(@(p) tank_dPdt(p, fi, mo, P1, V, R, T, rho, Kv), PP);

    % มองย้อนจากท้าย หาเวลาช่วงต่อเนื่องที่ |dP/dt| < tol
    idx = find(abs(dPdt) < dPdt_tol);
    if isempty(idx)
        % ยังไม่คงที่ ใช้ค่าท้ายสุดไปก่อน
        P_ss(k) = PP(end);
    else
        % ตรวจว่า idx ช่วงท้ายต่อเนื่องยาวพอไหม
        % เอาเฉพาะ idx ที่อยู่ใกล้ท้าย
        idx_tail = idx(idx > numel(tt)*0.5); % กันหลอกช่วงต้น
        if isempty(idx_tail)
            P_ss(k) = PP(end);
        else
            % หา segment ต่อเนื่องสุดท้าย
            breaks = [true; diff(idx_tail) > 1; true];
            bpos = find(breaks);
            seg_start = idx_tail(bpos(end-1));
            seg_end   = idx_tail(bpos(end)-1);

            % เช็คระยะเวลา segment
            if tt(seg_end) - tt(seg_start) >= tHold
                P_ss(k) = PP(seg_end); % หรือจะใช้ค่าเฉลี่ยช่วงนี้ก็ได้
            else
                P_ss(k) = PP(end);
            end
        end
    end

    % ให้รอบถัดไปเริ่มจากค่า steady-state รอบก่อน (เหมือนปรับ mi ทีละขั้น)
    P0 = P_ss(k);
end

% คำนวณคอลัมน์อื่นในตาราง
dMi  = [NaN; diff(mi_vec)];
dP   = [NaN; diff(P_ss)];
gain = dP ./ dMi;

% แสดงตาราง
Tbl = table(mi_vec, P_ss, dMi, dP, gain, ...
    'VariableNames', {'m_i','Pressure_in_Tank_P','DeltaMi_n_n1','DeltaP_n_n1','Gain_DeltaP_over_DeltaMi'});
disp(Tbl);

% plot
figure; plot(mi_vec, P_ss, 'LineWidth', 1.5);
grid on; xlabel('m_i (%)'); ylabel('P in tank (psi)');
title('Tank Pressure vs m_i (Dynamic steady-state)');

figure; plot(mi_vec, gain, 'LineWidth', 1.5);
grid on; xlabel('m_i (%)'); ylabel('\DeltaP/\Deltam_i (psi/%)');
title('Incremental Gain');

%% -------- local function --------
function dPdt = tank_dPdt(P, fi, mo, P1, V, R, T, rho, Kv)
    % Control Valve outflow
    % fo = Kv*mo*sqrt(P*(P-P1)), ระวัง P < P1 จะเป็นค่าจินตภาพ
    if P <= P1
        fo = 0;
    else
        fo = Kv * mo * sqrt(P*(P - P1));
    end

    % Tank dynamics
    dPdt = (R*T/V) * rho * (fi - fo);
end
