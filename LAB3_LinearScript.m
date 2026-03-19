% MATLAB Script for Linearization Lab
clear; clc;

% 1. กำหนดค่าคงที่จากโจทย์
Cv = 28.0;               % Valve Coefficient (gpm/psi)
rho_liquid = 70;         % ความหนาแน่นของเหลว (lb/ft3)
rho_water = 62.4;        % ความหนาแน่นของน้ำ (lb/ft3)
Gf = rho_liquid / rho_water; % Specific Gravity

% 2. กำหนดจุดทำงาน (Operating Point)
P_bar = 2.0; 

% 3. คำนวณค่าคงที่สำหรับสมการ Linearization
% f(P_bar) ณ จุดทำงาน
f_bar = Cv * sqrt(P_bar / Gf); 
% ความชัน (Slope) จากการ Diff: Cv / (2 * sqrt(Gf) * sqrt(P_bar))
slope = Cv / (2 * sqrt(Gf) * sqrt(P_bar));

% 4. สร้างช่วงความดัน delta P(t) ตามตาราง
P_t = (0.50:0.25:3.50)'; % สร้าง vector จาก 0.5 ถึง 3.5 เพิ่มทีละ 0.25

% 5. คำนวณค่าต่างๆ ในตาราง
flow_actual = Cv .* sqrt(P_t ./ Gf);          % คำนวณจากสมการจริง
flow_linear = f_bar + slope .* (P_t - P_bar); % คำนวณจากสมการเชิงเส้น
error = flow_actual - flow_linear;           % คำนวณค่าความต่าง

% 6. แสดงผลลัพธ์ในรูปแบบตาราง
T = table(P_t, flow_actual, flow_linear, error, ...
    'VariableNames', {'Delta_P_psi', 'Flow_Actual', 'Flow_Linear', 'Error'});

disp('--- ตารางผลการคำนวณ Linearization ---');
disp(T);

% 7. (Option) พลอตกราฟเปรียบเทียบ
plot(P_t, flow_actual, 'b-o', 'LineWidth', 1.5); hold on;
plot(P_t, flow_linear, 'r--*', 'LineWidth', 1.5);
grid on;
xlabel('\DeltaP (psi)'); ylabel('Flow rate');
legend('Actual (Square Root)', 'Linear Approximation');
title('Comparison between Actual and Linearized Flow');