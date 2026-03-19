%% Arrhenius: k(T) = k0 * exp(-E/(R*T))
% Given:
k0 = 2.4648e10;          % pre-exponential factor
E  = 22000;              % 22000 Kcal/Kmol  == 22000 cal/mol (unit-consistent with R below)
R  = 1.987;              % cal/(mol*K)

% Linearization point:
Tbar_C = 300;            % degC
Tbar   = Tbar_C + 273;   % K (ตามโจทย์ใช้ 573 K)

% Temperature range (degC) for table:
T_C = (290:2:310).';
T_K = T_C + 273;

% Actual Arrhenius
k_actual = k0 .* exp(-E ./ (R .* T_K));

% Linear approximation: k_lin(T) = kbar + (dk/dT)|Tbar * (T - Tbar)
k_bar = k0 * exp(-E/(R*Tbar));
dkdT_bar = k_bar * (E/(R*Tbar^2));     % derivative at Tbar

k_linear = k_bar + dkdT_bar .* (T_K - Tbar);

% Error (Actual - Linear)
err = k_actual - k_linear;

% Display table
T = table(T_C, k_actual, k_linear, err, ...
    'VariableNames', {'T_C','K_Actual','K_Linear','Error_ActualMinusLinear'});
disp(T);

% Plot
figure;
plot(T_C, k_actual, 'LineWidth', 1.5); hold on;
plot(T_C, k_linear, '--', 'LineWidth', 1.5);
grid on;
xlabel('T (^{\circ}C)');
ylabel('k');
title('Arrhenius k(T): Actual vs Linearized around 300^{\circ}C');
legend('k Actual','k Linear','Location','best');

% Show linear equation explicitly (in K)
fprintf('Linear model around Tbar = %g K:\n', Tbar);
fprintf('k_lin(T) = %.6g + (%.6g)*(T - %.6g)\n', k_bar, dkdT_bar, Tbar);
