%pwmthingy() 
%chargraph() 
%spdT() 
%hz_spd_ripple_check()
%currentcalib()
%initialFFT()
%raw()
%km_finder()
%bridgey()
function []=bridgey()
figure()

load("C:\Users\Legion Pro5\Desktop\super sweep\filtered speed 500Hz duty sweep sign.mat")

plot(data.time,double(data.data(:)),'LineWidth',4)
title("กราฟแสดงการเก็บข้อมูลความเร็วเชิงมุมในแต่ละ Duty Cycle แบบ Sign-Magnitude ด้วยความถี่ 500Hz")
xlabel("เวลา (s)")
ylabel("ความเร็วเชิงมุม (Rad/s)")
load("C:\Users\Legion Pro5\Desktop\super sweep\filtered speed 500Hz duty sweep lock.mat")
grid on
grid minor
figure()
plot(data.time,double(data.data(:)),'LineWidth',4)
grid on
grid minor
title("กราฟแสดงการเก็บข้อมูลความเร็วเชิงมุมในแต่ละ Duty Cycle แบบ Lock-Anti Phase ด้วยความถี่ 500Hz")
xlabel("เวลา (s)")
ylabel("ความเร็วเชิงมุม (Rad/s)")
figure()
grid on
grid minor
load("C:\Users\Legion Pro5\Desktop\super sweep\filtered current 500Hz duty sweep sign.mat")
plot(data.time,double(data.data(:)),'LineWidth',2)
xlabel("เวลา (s)")
ylabel("กระแส (A)")
title("กราฟแสดงการเก็บข้อมูลกระแสในแต่ละ Duty Cycle แบบ Sign-Magnitude ด้วยความถี่ 500Hz")
grid on
grid minor
figure()
load("C:\Users\Legion Pro5\Desktop\super sweep\filtered current 500Hz duty sweep lock.mat")
plot(data.time,double(data.data(:)),'LineWidth',2)
xlabel("เวลา (s)")
ylabel("กระแส (A)")
title("กราฟแสดงการเก็บข้อมูลกระแสในแต่ละ Duty Cycle แบบ Lock-Anti Phase ด้วยความถี่ 500Hz")
grid on
grid minor

end
function km_avg = km_finder()
%duty cycle 0% 20% 40% 60% 80% 100%

T_500   = [0, 0.0428, 0.086,  0.1337, 0.1753, 0.2007];
T_1000  = [0, 0.0363, 0.0786, 0.1214, 0.1672, 0.2048];
T_10000 = [0, 0.0388, 0.0797, 0.1242, 0.1673, 0.208];
files = [
    "C:\Users\Legion Pro5\Desktop\super sweep\current 500Hz duty cycle per 20% stall.mat"
    "C:\Users\Legion Pro5\Desktop\super sweep\current 1000Hz duty cycle per 20% stall.mat"
    "C:\Users\Legion Pro5\Desktop\super sweep\current 10000Hz duty cycle per 20% stall.mat"
    ];
T_all  = {T_500, T_1000, T_10000};
I_all  = cell(1, 3);
km_all = cell(1, 3);

for f = 1:3
    load(files(f))
    I = double(data.data(:));
    is_on = I > 0.3;
    rise = find(diff([0; is_on]) == 1);
    valid = rise(arrayfun(@(r) r + 2000 <= numel(I) && mean(is_on(r:r+2000)) > 0.95, rise));
    valid = valid([true; diff(valid) > 5000]);
    pulse_I = arrayfun(@(r) mean(I(r + find(I(r:r+300) == max(I(r:r+300)), 1) - 1 + (0:999))), valid);
    
    I_all{f}  = mean(reshape(pulse_I, 3, 5), 1);
    km_all{f} = T_all{f}(2:end) ./ I_all{f};
end

[I_500, I_1000, I_10000]    = I_all{:};
[km_500, km_1000, km_10000] = km_all{:};
km_avg = (mean(km_500) + mean(km_1000) + mean(km_10000)) / 3;



figure()
plot(I_500, T_500(2:end), '-o', 'LineWidth', 4)
hold on
plot(I_1000, T_1000(2:end), '-o', 'LineWidth', 4)
plot(I_10000, T_10000(2:end), '-o', 'LineWidth', 4)


legend('500Hz', '1000Hz', '10000Hz')
xlabel('Stall Current (A)')
ylabel('Stall Torque (N\cdotm)')
title('กราฟแสดงความสัมพันธ์ระหว่าง Stall Current และ Stall Torque (Slope = k_t)')
grid on
grid minor


end
function []=raw()
%ใช้ set(findobj('Type', 'axes'), 'XLim', [1264 1580]) เพื่อzoomเข้าสำหรับEX1
    figure()
    load("C:\Users\Legion Pro5\Desktop\super sweep\raw speed super sweep 1.mat")
    spd1=data.data;
    time1=data.time;
    load("C:\Users\Legion Pro5\Desktop\super sweep\raw speed super sweep 2.mat")
    spd2=data.data;
    time2=data.time;
    load("C:\Users\Legion Pro5\Desktop\super sweep\raw speed super sweep 3.mat")
    spd3=data.data;
    time3=data.time;
    plot(time1,spd1,'Color','r','LineWidth',1)
    hold on
    plot(time2,spd2,'Color','g','LineWidth',1)
    plot(time3,spd3,'Color','b','LineWidth',1)
    legend("การทดลองรอบที่ 1","การทดลองรอบที่ 2","การทดลองรอบที่ 3")
    grid on 
    grid minor 
    xlabel('เวลา (s)')
    ylabel('ความเร็วเชิงมุม (rad/s)')
    title('กราฟแสดงการเก็บข้อมูลความเร็วเชิงมุม(No-load)ในแต่ละช่วง Duty Cycle และความถี่ ที่ยังไม่ผ่านการทำ Signal Conditioning')
    xlim([0,2870])
    ylim([-250,250])
    figure
    
    load("C:\Users\Legion Pro5\Desktop\super sweep\filtered speed super sweep 1.mat")
    spd1=double(data.data(:));
    time1=data.time;
    load("C:\Users\Legion Pro5\Desktop\super sweep\filtered speed super sweep 2.mat")
    spd2=double(data.data(:));
    time2=data.time;
    load("C:\Users\Legion Pro5\Desktop\super sweep\filtered speed super sweep 3.mat")
    spd3=double(data.data(:));
    time3=data.time;
    plot(time1,spd1,'Color','r','LineWidth',1)
    hold on
    plot(time2,spd2,'Color','g','LineWidth',1)
    plot(time3,spd3,'Color','b','LineWidth',1)
    legend("การทดลองรอบที่ 1","การทดลองรอบที่ 2","การทดลองรอบที่ 3")
    grid on 
    grid minor 
    xlabel('เวลา (s)')
    ylabel('ความเร็วเชิงมุม (rad/s)')
    title('กราฟแสดงการเก็บข้อมูลความเร็วเชิงมุม(No-load)ในแต่ละช่วง Duty Cycle และความถี่ ที่ผ่านการทำ Signal Conditioning')
    xlim([0,2870])
    figure()
    load("C:\Users\Legion Pro5\Desktop\super sweep\filtered current super sweep 1.mat")
    I1=-1*double(data.data(:));
    t1=data.time;
    load("C:\Users\Legion Pro5\Desktop\super sweep\filtered current super sweep 2.mat")
    I2=-1*double(data.data(:));
    t2=data.time;
    load("C:\Users\Legion Pro5\Desktop\super sweep\filtered current super sweep 3.mat")
    I3=-1*double(data.data(:));
    t3=data.time;
    plot(t1,I1,'Color','r','LineWidth',1)
    hold on
    plot(t2,I2,'Color','g','LineWidth',1)
    plot(t3,I3,'Color','b','LineWidth',1)
    legend("การทดลองรอบที่ 1","การทดลองรอบที่ 2","การทดลองรอบที่ 3")
    xlim([0,2870])
    grid on
    grid minor
    ylabel("กระแสมอเตอร์ (A)")
    xlabel("เวลา (s)")
    title("กราฟแสดงการเก็บข้อมูลกระแส(No-load)ในแต่ละช่วง Duty Cycle และความถี่ที่ผ่านการทำ Signal Conditioning เพียงเล็กน้อย")
    figure()
    plot(t1,movmean(I1,5000),'Color','r','LineWidth',1)% กราฟ EX1 ใช้ 500 กราฟ EX2 ใช้ 5000
    hold on
    plot(t2,movmean(I2,5000),'Color','g','LineWidth',1)
    plot(t3,movmean(I3,5000),'Color','b','LineWidth',1)
    ylabel("กระแสมอเตอร์ (A)")
    xlabel("เวลา (s)")
    title("กราฟแสดงการเก็บข้อมูลกระแส(No-load)ในแต่ละช่วง Duty Cycle และความถี่ที่ผ่านการทำ Signal Conditioning")
    xlim([0,2870])
    grid on
    grid minor
    legend("การทดลองรอบที่ 1","การทดลองรอบที่ 2","การทดลองรอบที่ 3")
    figure()
    load("C:\Users\Legion Pro5\Desktop\super sweep\current 500Hz duty cycle per 20% stall.mat")
    plot(data.time,double(data.data(:)),'LineWidth',4)
    title("ภาพแสดงการเก็บข้อมูลกระแสในสภาวะ Stall ที่ ความถี่ 500Hz")
    grid on
    grid minor
    xlabel("เวลา (s)")
    ylabel("กระแส (A)")
    figure()
    load("C:\Users\Legion Pro5\Desktop\super sweep\current 500Hz duty cycle per 20% stall.mat")
    plot(data.time,double(data.data(:)),'LineWidth',4)
    hold on
    load("C:\Users\Legion Pro5\Desktop\super sweep\current 1000Hz duty cycle per 20% stall.mat")
    plot(data.time,double(data.data(:)),'LineWidth',4)
load("C:\Users\Legion Pro5\Desktop\super sweep\current 10000Hz duty cycle per 20% stall.mat")
plot(data.time,double(data.data(:)),'LineWidth',4)
    legend("500Hz","1000Hz","10000Hz")

    title("ภาพแสดงการเก็บข้อมูลกระแสในสภาวะ Stall ที่ความถี่ต่างๆ")
    grid on
    grid minor
    xlabel("เวลา (s)")
    ylabel("กระแส (A)")

end
function [I1,I2,I3,avg_I]=get_I_matrix()
load("C:\Users\Legion Pro5\Desktop\super sweep\filtered current super sweep 1.mat")
time1=data.time;
data1=double(data.data(:));
load("C:\Users\Legion Pro5\Desktop\super sweep\filtered current super sweep 2.mat")
time2=data.time;
data2=double(data.data(:));
load("C:\Users\Legion Pro5\Desktop\super sweep\filtered current super sweep 3.mat")
time3=data.time;
data3=double(data.data(:));
I1 = zeros(21, 9);
I2 = zeros(21, 9);
I3 = zeros(21, 9);

for j=1:21%inner duty cycle loop
    for i=12:315:2800%outer frequency loop
        I1(j,(i+303)/315)=-1*mean(data1(i*1000+(15000*j-15000):i*1000+1000+(15000*j-15000)));
        I2(j,(i+303)/315)=-1*mean(data2(i*1000+(15000*j-15000):i*1000+1000+(15000*j-15000)));
        I3(j,(i+303)/315)=-1*mean(data3(i*1000+(15000*j-15000):i*1000+1000+(15000*j-15000)));
        
        %plot((i+0.5)+(15*j-15),-1*mean(double(data.data(i*1000+(15000*j-15000):i*1000+1000+(15000*j-15000)))),'*')
    end
end
avg_I=(I1+I2+I3)/3;
for i=1:numel(avg_I)
    if avg_I(i)==0
        avg_I(i)=0.001;
    end
end
end
function [speed1,speed2,speed3,avg_speed]=get_speed_matrix()
load("C:\Users\Legion Pro5\Desktop\super sweep\raw speed super sweep 1.mat")
time1=data.time;
data1=double(data.data(:));
load("C:\Users\Legion Pro5\Desktop\super sweep\raw speed super sweep 2.mat")
time2=data.time;
data2=double(data.data(:));
load("C:\Users\Legion Pro5\Desktop\super sweep\raw speed super sweep 3.mat")
time3=data.time;
data3=double(data.data(:));
speed1 = zeros(21, 9);
speed2 = zeros(21, 9);
speed3 = zeros(21, 9);
for j=1:21%inner duty cycle loop
    for i=12:315:2800%outer frequency loop
        speed1(j,(i+303)/315)=mean(data1(i*1000+(15000*j-15000):i*1000+1000+(15000*j-15000)));
        speed2(j,(i+303)/315)=mean(data2(i*1000+(15000*j-15000):i*1000+1000+(15000*j-15000)));
        speed3(j,(i+303)/315)=mean(data3(i*1000+(15000*j-15000):i*1000+1000+(15000*j-15000)));
        %plot((i+0.5)+(15*j-15),mean(double(data.data(i*1000+(15000*j-15000):i*1000+1000+(15000*j-15000)))),'*')
    end
end
avg_speed=(speed1+speed2+speed3)/3;
for i=1:numel(avg_speed)
    if avg_speed(i)==0
        avg_speed(i)=0.001;
    end
end
end
function []=hz_spd_ripple_check()
figure()
[speed1,speed2,speed3,avg_speed]=get_speed_matrix();

freq = [5, 10, 50, 100, 500, 1000, 5000, 10000, 20000];


    
    semilogx(freq,speed1(1,:),'-o')
    hold on
    semilogx(freq,speed2(1,:),'-o')
    semilogx(freq,speed3(1,:),'-o')
    


grid on
grid minor
end
    
function []=currentcalib()
figure()
load("C:\Users\Legion Pro5\Desktop\super sweep\current calibration 1.5V sweep 6-1A.mat")
plot([6,5,4,3,2,1,0], [ mean(data.data(8000:9000)), mean(data.data(18000:19000)), mean(data.data(28000:29000)), mean(data.data(35000:36000)), mean(data.data(41000:42000)), mean(data.data(48000:49000)),mean(data.data(1000:2000))],'-o','LineWidth',4)
title("กราฟแสดงความสัมพันธ์ระหว่าง Current limit และค่า ADC จาก Hall-effect Current Sensor")
xlabel("กระแส Current limit (A)")
ylabel("ค่า ADC ที่อ่านได้จาก Hall-effect Current Sensor")
legend('ข้อมูลจริง','เส้นกราฟจาก Basic Fitting แบบ Linear')
grid on 
grid minor
end


function []=pwmthingy()
figure()
[speed1,speed2,speed3,avg_speed]=get_speed_matrix();%f-speed |duty
for i=1:11
       loglog([5,10,50,100,500,1000,5000,10000,20000],avg_speed(i,1:9),'-o','LineWidth',4)
       hold on
end
colororder(turbo(11));
title("กราฟแสดงความสัมพันธ์ระหว่างความเร็วเชิงมุม (Rad/s) และความถี่ (Hz) ใน Duty Cycle (%)ต่างๆในสภาวะ No-Load")
xlabel('ความถี่ PWM (Hz)')
ylabel('ความเร็วเชิงมุม (Rad/s)')
legend("100%","90%","80%","70%","60%","50%","40%","30%","20%","10%","0%")
grid on
grid minor
figure()%duty cycle-spd |f
for i=1:9
    semilogy([100,90,80,70,60,50,40,30,20,10,0.001],avg_speed(1:11,i),'-o','LineWidth',4)
    hold on
end
colororder(turbo(9));
grid on
grid minor
title("กราฟแสดงความสัมพันธ์ระหว่าง Duty Cycle (%) และความเร็วเชิงมุม (Rad/s) ในความถี่ PWM ต่างๆภายใต้สภาวะ No-Load")
xlabel('Duty Cycle (%)')
ylabel('ความเร็วเชิงมุม (Rad/s)')
legend("5Hz","10Hz","50Hz","100Hz","500Hz","1000Hz","5000Hz","10000Hz","20000Hz")
figure()
for i=1:9
    plot([100,90,80,70,60,50,40,30,20,10,0.01],avg_speed(1:11,i),'-o','LineWidth',4)
    hold on
end

colororder(turbo(9));
grid on
grid minor
title("กราฟแสดงความสัมพันธ์ระหว่าง Duty Cycle (%) และความเร็วเชิงมุม (Rad/s) ในความถี่ PWM ต่างๆภายใต้สภาวะ No-Load")
xlabel('Duty Cycle (%)')
ylabel('ความเร็วเชิงมุม (Rad/s)')
legend("5Hz","10Hz","50Hz","100Hz","500Hz","1000Hz","5000Hz","10000Hz","20000Hz")


[I1,I2,I3,I_avg]=get_I_matrix();

figure()%f-I| duty cycle
for i=1:11
    semilogx([5,10,50,100,500,1000,5000,10000,20000],I_avg(i,1:9),'-o','LineWidth',4)
    hold on
end
grid on
grid minor
colororder(turbo(11));
legend("100%","90%","80%","70%","60%","50%","40%","30%","20%","10%","0%")
xlabel("ความถี่ PWM (Hz)")
ylabel("กระแส (A)")
title("กราฟแสดงความสัมพันธ์ระหว่างความถี่ PWM (%) และกระแส (A) ในDuty Cycle (%)ต่างๆภายใต้สภาวะ No-Load")

figure() %dutycycle-I| frequency
for i=1:9
    plot([100,90,80,70,60,50,40,30,20,10,0.01],I_avg(1:11,i),'-o','LineWidth',4)
    hold on
end
colororder(turbo(9));
title("กราฟแสดงความสัมพันธ์ระหว่าง Duty Cycle (%) และกระแส (A) ในความถี่ PWM ต่างๆภายใต้สภาวะ No-Load")

legend("5Hz","10Hz","50Hz","100Hz","500Hz","1000Hz","5000Hz","10000Hz","20000Hz")

grid on
grid minor
xlabel("Duty cycle (%)")
ylabel("กระแส (A)")
T_500=[0,0.0428,0.086,0.1337,0.1753,0.2007];
T_1000=[0,0.0363,0.0786,0.1214,0.1672,0.2048];
T_10000=[0,0.0388,0.0797,0.1242,0.1673,0.208];
V=[0,2.4,4.8,7.2,9.6,12];
figure()%duty cycle-eff | f

T_l=linspace(0,2.044,1000);

eff_500=[0];
eff_1000=[0];
eff_10000=[0];
for i=2:numel(T_500)
   
    [eff_temp,a,b]=char(100000*T_500(i)/9.81, avg_speed(13 - 2*i, 5)*60/(2*pi), linspace(0, 100000*T_500(i)/9.81, 1000), T_500(i)*26404 + I_avg(13 - 2*i, 5)*1000, I_avg(13 - 2*i, 5)*1000, V(i));
    eff_500(end+1)=max(eff_temp);
    [eff_temp,a,b]=char(100000*T_1000(i)/9.81, avg_speed(13 - 2*i, 6)*60/(2*pi), linspace(0, 100000*T_1000(i)/9.81, 1000), T_1000(i)*26404 + I_avg(13 - 2*i, 6)*1000, I_avg(13 - 2*i, 6)*1000, V(i));
    eff_1000(end+1)=max(eff_temp);
    [eff_temp,a,b]=char(100000*T_10000(i)/9.81, avg_speed(13 - 2*i, 8)*60/(2*pi), linspace(0, 100000*T_10000(i)/9.81, 1000), T_10000(i)*26404 + I_avg(13 - 2*i, 8)*1000, I_avg(13 - 2*i, 8)*1000, V(i));
    eff_10000(end+1)=max(eff_temp);
   
end


%avg_speed
plot([0,20,40,60,80,100],eff_500,'-o','LineWidth',4)
hold on
plot([0,20,40,60,80,100],eff_1000,'-o','LineWidth',4)
plot([0,20,40,60,80,100],eff_10000,'-o','LineWidth',4)
legend('500Hz','1000Hz','10000Hz')
xlabel('Duty Cycle (%)')
ylabel('ประสิทธิภาพ (%)')
title('กราฟแสดงความสัมพันธ์ระหว่าง Duty Cycle (%) และ Efficiency (%) ในความถี่ PWM ต่างๆ')
grid on
grid minor
freqs = [500, 1000, 10000];
current_avg = zeros(3, 5); % rows: 500, 1000, 10000 Hz | cols: 20, 40, 60, 80, 100%

for k = 1:3
    f = load(sprintf('C:\\Users\\Legion Pro5\\Desktop\\super sweep\\current %dHz duty cycle per 20%% stall.mat', freqs(k)));
    fn = fieldnames(f);
    d = f.(fn{1});
    try t = d.time(:); y = d.data(:); catch, t = d.Time(:); y = d.Data(:); end

    on = y > 0.4;
    s = find(diff([0; on]) == 1);
    e = find(diff([on; 0]) == -1);
    keep = (t(e) - t(s)) > 2;
    s = s(keep); e = e(keep);

    m = zeros(1, 15);
    for p = 1:15
        mid = (t(s(p)) + t(e(p))) / 2;
        idx = abs(t - mid) <= 0.5;
        m(p) = mean(y(idx));
    end
    current_avg(k, :) = mean(reshape(m, 3, 5), 1);
end
figure()
current_avg
plot([0,20,40,60,80,100],[0,current_avg(1,:)],"-o","LineWidth",4)
hold on
plot([0,20,40,60,80,100],[0,current_avg(2,:)],"-o","LineWidth",4)
plot([0,20,40,60,80,100],[0,current_avg(3,:)],"-o","LineWidth",4)
legend("500Hz","1000Hz","10000Hz")
xlabel("Duty Cycle (%)")
ylabel("กระแส (A)")
grid on 
grid minor
title("กราฟแสดงความสัมพันธ์ระหว่าง Duty Cycle (%) และกระแส (A) ในสภาวะ Stall ด้วยความถี่ PWM ต่างๆ")




end




function []=spdT()%T-spd in different PWM voltage at 500Hz
figure()
grid on 
grid minor
ylabel("Speed(rad/s)")
xlabel("Torque(N*m)")
title("กราฟแสดงความสัมพันธ์ระหว่างแรงบิดและความเร็วเชิงมุมใน Duty Cycle ต่างๆ ที่ความถี่ 500Hz")
hold on
[speed1,speed2,speed3,avg_speed]=get_speed_matrix();%stall_torque 0% 20% 40% 60% 80% 100%
T_list1=[0,0.03858273,0.08331633,0.129951108,0.171329688,0.199511856];
T_list2=[0,0.047193948,0.089802702,0.139456998,0.18508527,0.205103556];
T_list3=[0,0.04249692,0.084882006,0.131740452,0.16942851,0.197498844];
T_list=(T_list1+T_list2+T_list3)/3
for i=1:6
plot([T_list(i),0], [0,speed1(13-2*i,5)], '-o', LineWidth=4)

end
colororder(turbo(6));


legend("0%","20%","40%","60%","80%","100%")

end

function [] = initialFFT()
load("C:\Users\Legion Pro5\Desktop\super sweep\raw speed super sweep 1.mat")


fs=1000;
figure()

for i=10:315:2760

speed_freq=fft(data.data(i*1000+500:1000*i+4500));
f=(0:length(speed_freq)-1)*fs/length(speed_freq);
mag=abs(speed_freq)/(length(speed_freq));
semilogx(f,mag,'LineWidth',1)
hold on
end
title("กราฟแสดงผลลัพธ์จากการใช้ FFT() ในการวิเคราะห์ความถี่มอเตอร์")
legend("5Hz","10Hz","50Hz","100Hz","500Hz","1000Hz","5000Hz","10000Hz","20000Hz")
colororder(turbo(9));
grid on
grid minor
xlabel("ความถี่ (Hz)")
ylabel("ความเร็วเชิงมุม (Rad/s)")
xlim([0,500])
figure()

for i=10:315:2760

    speed_freq=fft(data.data(i*1000+500:1000*i+4500));
    f=(0:length(speed_freq)-1)*fs/length(speed_freq);
    mag=abs(speed_freq)/(length(speed_freq));
    plot(f,mag,'-o','LineWidth',4)
    hold on
end

title("กราฟแสดงผลลัพธ์จากการใช้ FFT() ในการวิเคราะห์ความถี่มอเตอร์")
legend("5Hz","10Hz","50Hz","100Hz","500Hz","1000Hz","5000Hz","10000Hz","20000Hz")
colororder(turbo(9));
grid on
grid minor
xlabel("ความถี่ (Hz)")
ylabel("ความเร็วเชิงมุม (Rad/s)")
xlim([0,500])
end
function []=chargraph()

T_st=0.204482256*100000/9.81;
[speed1,speed2,speed3,avg_speed]=get_speed_matrix();
w_nl=mean(avg_speed(1,5))*60/(2*pi);
T_l=linspace(0,T_st,1000);
load("C:\Users\Legion Pro5\Desktop\super sweep\current 500Hz duty cycle per 20% stall.mat")

I_st=1000*(mean(data.data(454208:455208))+mean(data.data(491181:492181))+mean(data.data(528181:529181)))/3;
[I1,I2,I3,avg_I]=get_I_matrix();
I_nl=mean(avg_I(1,5)*1000);
[eff,T_l,P]=char(T_st,w_nl,T_l,I_st,I_nl,12);
figure();
plotBox = [0.10, 0.15, 0.56, 0.72]; 
xLimRange = [0, T_st * 1.05];

ax1 = axes('Position', plotBox);
p1 = plot(ax1, [T_st, 0], [0, w_nl], 'Color', [0.18 0.35 0.53], 'LineWidth', 2.5);
xlim(ax1, xLimRange);
ylim(ax1, [0, w_nl * 1.05]);
xlabel(ax1, 'Torque (g\cdotcm)', 'FontWeight', 'bold');
ylabel(ax1, 'Speed (rpm)', 'FontWeight', 'bold');
title(ax1, 'DC Motor Performance (500 Hz)');
grid(ax1, 'on');
box(ax1, 'off');

ax2 = axes('Position', plotBox, 'Color', 'none', ...
    'YAxisLocation', 'right', 'XColor', 'none', 'Box', 'off');
hold(ax2, 'on');
p2 = plot(ax2, [0, T_st], [I_nl, I_st], 'Color', [0.65 0.12 0.12], 'LineWidth', 2.5);
xlim(ax2, xLimRange);
ylim(ax2, [0, max(I_nl, I_st) * 1.05]);
ylabel(ax2, 'Current (mA)', 'FontWeight', 'bold');

ax3_data = axes('Position', plotBox, 'Color', 'none', 'XColor', 'none', 'YColor', 'none');
hold(ax3_data, 'on');
p3 = plot(ax3_data, T_l, P, 'Color', [0.72 0.70 0.65], 'LineWidth', 2.5);
xlim(ax3_data, xLimRange);
ylim(ax3_data, [0, max(P) * 1.10]);

ax3_ruler = axes('Position', [0.74, plotBox(2), 0.001, plotBox(4)], ...
    'Color', 'none', 'YAxisLocation', 'right', 'XColor', 'none', 'Box', 'off');
ylim(ax3_ruler, [0, max(P) * 1.10]);
ylabel(ax3_ruler, 'Power (mW)', 'FontWeight', 'bold');

ax4_data = axes('Position', plotBox, 'Color', 'none', 'XColor', 'none', 'YColor', 'none');
hold(ax4_data, 'on');
p4 = plot(ax4_data, T_l, eff, 'Color', [0.28 0.50 0.22], 'LineWidth', 2.5);
xlim(ax4_data, xLimRange);
ylim(ax4_data, [0, max(eff) * 1.10]);

ax4_ruler = axes('Position', [0.83, plotBox(2), 0.001, plotBox(4)], ...
    'Color', 'none', 'YAxisLocation', 'right', 'XColor', 'none', 'Box', 'off');
ylim(ax4_ruler, [0, max(eff) * 1.10]);
ylabel(ax4_ruler, 'Efficiency (%)', 'FontWeight', 'bold');


linkaxes([ax1, ax2, ax3_data, ax4_data], 'x');
legend(ax1, [p1, p2, p3, p4], {'Speed', 'Current', 'Power (Out)', 'Efficiency'}, ...
    'Position', [0.86, 0.76, 0.12, 0.15], 'Box', 'off');
% --- Find operating point at Maximum Efficiency ---
w_curve = w_nl * (1 - T_l / T_st);                 % Speed curve (rpm)
I_curve = I_nl + (I_st - I_nl) * (T_l / T_st);     % Current curve (mA)

[max_eff, idx] = max(eff);

T_opt_gcm = T_l(idx);              % Torque (g*cm)
T_opt_Nm  = T_opt_gcm * 9.81e-5;   % Torque (N*m)
w_opt_rpm = w_curve(idx);          % Speed (rpm)
w_opt_rad = w_opt_rpm * 2*pi / 60; % Speed (rad/s)
I_opt_mA  = I_curve(idx);          % Current (mA)
I_opt_A   = I_opt_mA / 1000;       % Current (A)
P_opt_mW  = P(idx);                % Power Out (mW)

fprintf('\n=== จุดทำงานที่ประสิทธิภาพสูงสุด (12V, 500Hz) ===\n');
fprintf('Max Efficiency : %.2f %%\n', max_eff);
fprintf('Torque         : %.2f g*cm  (%.4f N*m)\n', T_opt_gcm, T_opt_Nm);
fprintf('Speed          : %.2f rpm   (%.2f rad/s)\n', w_opt_rpm, w_opt_rad);
fprintf('Current        : %.2f mA    (%.3f A)\n', I_opt_mA, I_opt_A);
fprintf('Output Power   : %.2f mW    (%.2f W)\n', P_opt_mW, P_opt_mW/1000);

% Optional: Mark the peak efficiency dot directly on the graph
plot(ax4_data, T_opt_gcm, max_eff, 'o', 'Color', [0.28 0.50 0.22], ...
    'MarkerFaceColor', [0.28 0.50 0.22], 'MarkerSize', 8);
xline(ax1, T_opt_gcm, '--k', sprintf('Max Eff = %.1f%%', max_eff), ...
    'LabelVerticalAlignment', 'bottom');
end
function [eff,T_l,P]=char(T_st,w_nl,T_l,I_st,I_nl,V)%me do 500Hz

k_t   = (T_st * 9.81e-5) / ((I_st - I_nl) / 1000);
V_eff = (k_t * (w_nl * 2 * pi / 60)) / (1 - I_nl / I_st);
P=(-(w_nl/T_st)*T_l.^2+w_nl*T_l)*(2*pi*9.81/6000);
p_in=V_eff*T_l*((I_st-I_nl)/T_st)+I_nl*V_eff;
eff=100*P./p_in;


end

