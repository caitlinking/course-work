#Python 3.5.1 was used. 
#Everything is in metric

import math #Lets us use the power function lower down
import sys #Probably lets us use the print redirect statements directly under this.

#These statements let us redirect the printouts to an excel file.

#Comment out the files that aren't being used while you're editing.
#sys.stdout = open('C:/Users/kingb_000/Desktop/Output.csv', 'w') #Brian's laptop
sys.stdout = open('C:/Users/Caitlin/Desktop/Output.csv', 'w') #Caitlin's laptop
#sys.stdout = open('//fileserve/StudentFiles$/cking12/Desktop/Output.csv', 'w')
#sys.stdout = open('//fileserve/StudentFiles$/SKIRBY12/Desktop/Output.csv', 'w')
#sys.stdout = open('//fileserve/StudentFiles$/KHARRIS11/Desktop/Output.txt', 'w')

#The variables you'll need to change are in VARIABLE CONSTANTS and VARIABLE ARRAYS. 

#VARIABLE CONSTANTS
oneTimeStep = 180 #Time, in seconds, between data points. Must be able to divide evenly into 3600
hours_in_day = 24
secs_in_hour = 3600
time_steps = (hours_in_day*secs_in_hour)//oneTimeStep #Total number of data points in a day
hour_time_steps = secs_in_hour//oneTimeStep #Number of data points in each hour

morning_time = time_steps*8/hours_in_day #8:00am
night_time = time_steps*17/hours_in_day  #5:00pm
min_temp = 42  #Target temp in °C

hs_density = 2500      #Density of heatsink in kg/m^3 (2500 = sandstone)
Cp_hs = .9             #Specific heat of heatsink in kJ/kg*K (.9 = sandstone)
void_space = .25       #Our heatsink is modeled using perfect spheres, so sphere packing prevents anything more than a 75% fill by volume
m_full_container = 77*hs_density*(1-void_space)     #Mass of a full container (75% max cuz sphere packing) based on the heatsink density. 77m^3 = volume of container


#VARIABLE ARRAYS
#solar collector surface area
A_surface_arr = [30] 



#Percent full of dryer and number of trays
tray_number = [18,15,13,10]
m_grapes_init_arr = [None]*len(tray_number)
for tray_number_value in range(len(tray_number)):
    m_grapes_init_arr[tray_number_value] = 334*tray_number[tray_number_value]

#heat sink mass
m_hs_arr = [m_full_container*.25,m_full_container*.5,m_full_container*.75,m_full_container*.95] #, 100000, 250000] currently only using 50K

#heat sink initial temp
T_hs_init_arr = [55]


#GLOBAL CONSTANTS
print_headers_once = 0
iteration = 0

sigma = .0000000000567 #Stephen Boltzmann Constant
e = .98                #Emissivity of black pain
rho = 1.18             #Average density of air. The density decreases significantly at higher temperatures, but here's the average.
Cp_air = 1.005         #Specific heat of air
eff = .8               #Efficiency. This is a fairly arbitrary number that we've repeatedly determined is realistic enough


#DESIGN CONSTANTS

#Areas of the ducts in each state
A_1 = 1
A_6 = 1
A_7 = 1
A_11 = 1
A_13 = 1

v_6 = 0 #Air velocity coming in from outside, bypassing solar collectors and heatsink

h_c_5 = .15 #Coefficient of convection in state 5
h_c_8 = .1  #Coefficient of convection in state 8
h_c_12 = .1 #Coefficient of convection in state 12
h_c_outside = .025 #Coefficient of convection 

T_sky = -13.0 #Temperature of the sky in °C
alpha = 1/8   #Absorptivity of the solar collector surface

A_hs = 100  
A_top_hs = 30  #Area of the top of the shipping container (8'x40' in m^2)
A_end_hs = 6   #Area of door side of shipping container (8'x8' in m^2)
A_side_hs = 30 #Area of the side of the shipping container (8'x40' in m^2)

td_hs = 24     #The distance in meters the air travels through the heatsink (down and back, 12m each way)

N_grapes = 5000      #Number of grapes in the dryer
A_grape = .00006864  #Surface area of a single grape
T_grapes = 29        #Temperature of the grapes in the dryer
A_grape_total = 0    #Total surface area of all the grapes


#FUNCTIONS
def getEnthalpy(temp):
    enthalpy = temp + 273
    return enthalpy

def getTemp(enthalpy):
    temp = enthalpy - 273
    return temp


#GLOBAL ARRAYS
T_1       = [18,17,17,16,15,15, 18,21,24,26,27,28,          28,29,28,27,26,24,             23,22,21,20,19,18]
q_dot_sun = [0,0,0,0,0,0,       0,.106,.34,.563,.729,.836,  .872,.836,.729,.563,.34,.106,  0,0,0,0,0,0,     ]
q_dot_N   = [0,0,0,0,0,0,       0,.035,.064,.087,.104,.113, .116,.113,.104,.087,.064,.035, 0,0,0,0,0,0,     ]   
q_dot_E   = [0,0,0,0,0,0,       0,.575,.786,.742,.565,.296, .124,.113,.104,.087,.064,.032, 0,0,0,0,0,0,     ]
q_dot_W   = [0,0,0,0,0,0,       0,.032,.064,.087,.104,.113, .124,.296,.565,.742,.786,.575, 0,0,0,0,0,0,     ]
q_dot_S   = [0,0,0,0,0,0,       0,.073,.236,.412,.552,.640, .669,.640,.552,.412,.236,.073, 0,0,0,0,0,0,     ]


#ARRAY DECLARATIONS
#Creates a bunch of empty spaces in an array to fill in later
T_1_multi         = [None]*time_steps
q_dot_sun_multi   = [None]*time_steps
q_dot_N_multi     = [None]*time_steps
q_dot_E_multi     = [None]*time_steps
q_dot_W_multi     = [None]*time_steps
q_dot_S_multi     = [None]*time_steps
v_1_multi         = [None]*time_steps
v_7_multi         = [None]*time_steps
h_1_arr           = [None]*time_steps
h_3_arr           = [None]*time_steps
T_3_arr           = [None]*time_steps
Q_dot_solar_2_arr = [None]*time_steps
Q_dot_hs_arr      = [None]*time_steps
Q_hs_arr          = [None]*time_steps
Q_hs_onepass_arr  = [None]*time_steps
Q_rad_arr         = [None]*time_steps
Q_gain_arr        = [None]*time_steps
Q_convection_arr  = [None]*time_steps
T_hs_arr          = [None]*time_steps
T_5_arr           = [None]*time_steps
h_5_arr           = [None]*time_steps
h_7_arr           = [None]*time_steps
v_7_arr           = [None]*time_steps
Q_dot_solar_8_arr = [None]*time_steps
h_9_arr           = [None]*time_steps
T_9_arr           = [None]*time_steps
m_dot_11_arr      = [None]*time_steps
v_11_arr          = [None]*time_steps
h_11_arr          = [None]*time_steps
T_11_arr          = [None]*time_steps
Q_dot_conv_12_arr = [None]*time_steps
evap_rate_arr     = [None]*time_steps
time_to_dry_arr   = [None]*time_steps
m_grapes_arr      = [None]*(time_steps+1)
time_fill_dryer_arr         = [None]*time_steps
MR_arr                      = [None]*time_steps
sat_dryer_air_density_arr   = [None]*time_steps
sat_ambient_air_density_arr = [None]*time_steps
m_dot_13_arr      = [None]*time_steps
h_13_arr          = [None]*time_steps
T_13_arr          = [None]*time_steps


# Iterate for 24 steps (hours in a day)
for i in range(hours_in_day):
    # Iterate for n steps (chunks of a day) 
    for n in range(hour_time_steps):
        # Find the slope between the  'front' of the hour and the 'end' of the hour
        next_point = (i+1)%hours_in_day # next_point will equal 0 when i = 23
        
        slopeT   = T_1[next_point]       - T_1[i]
        slopeq   = q_dot_sun[next_point] - q_dot_sun[i]
        slopeq_N = q_dot_N[next_point]   - q_dot_N[i]
        slopeq_E = q_dot_E[next_point]   - q_dot_E[i]
        slopeq_W = q_dot_W[next_point]   - q_dot_W[i]
        slopeq_S = q_dot_S[next_point]   - q_dot_S[i]
       
        # Find the actual temperature based on the timestep
        T_1_multi      [n + i * hour_time_steps] = T_1[i]       + slopeT   * oneTimeStep*n/secs_in_hour
        q_dot_sun_multi[n + i * hour_time_steps] = q_dot_sun[i] + slopeq   * oneTimeStep*n/secs_in_hour
        q_dot_N_multi  [n + i * hour_time_steps] = q_dot_N[i]   + slopeq_N * oneTimeStep*n/secs_in_hour
        q_dot_E_multi  [n + i * hour_time_steps] = q_dot_E[i]   + slopeq_E * oneTimeStep*n/secs_in_hour
        q_dot_W_multi  [n + i * hour_time_steps] = q_dot_W[i]   + slopeq_W * oneTimeStep*n/secs_in_hour
        q_dot_S_multi  [n + i * hour_time_steps] = q_dot_S[i]   + slopeq_S * oneTimeStep*n/secs_in_hour


for T_hs_init_value in T_hs_init_arr:
    for A_surface_value in A_surface_arr:
        for m_grapes_init_value in m_grapes_init_arr:

            rho_grapes = 1000 #Density of the grapes
            diameter_of_grapes = .0254  #1" in meters
            N_grapes = m_grapes_init_value/(rho_grapes*4/3*3.1415926*(math.pow((diameter_of_grapes/2),3))) #Total number of grapes based on initial mass and volume
            volume_grapes = m_grapes_init_value/rho_grapes #Total volume of grapes in dryer
            volume_shipping_container = 72.5 #In m^3
            volume_air_dryer = volume_shipping_container - volume_grapes #Volume of air left in the dryer once the grapes have been put in
            m_air_dryer = rho*volume_air_dryer #Mass of air in the dryer

            for m_hs_value in m_hs_arr:
                volume_hs_air = volume_shipping_container-m_hs_value/hs_density 
                m_air = rho*volume_hs_air
                out_of_energy = 0
                raisins = 0

                for days in range(14): #Determines number of days to run the system
                    for i in range(time_steps): #Determines how many times to run
                        
                        KeepGoing = 1 #Keep running the while loop 
                        v_11_arr[i] = 3 #Determines upper limit of air velocity
                    
                        while KeepGoing == 1: 
                            v_11_arr[i] = v_11_arr[i] - .05 #Decrement the velocity down and run the timestep again
                            
                            if i < morning_time: #if early morning 
                                v_1_value = v_11_arr[i] #Pull air through heatsink in the early morning
                                v_7_arr[i] = 1 #Pull air through the solar collector at 1m/s cuz Python doesn't like dividing by zero
                            elif i > night_time: #if night 
                                v_1_value = v_11_arr[i] #Pull air through heatsink in the early morning
                                v_7_arr[i] = 1 #Pull air through the solar collector at 1m/s cuz Python doesn't like dividing by zero
                            else: #day 
                                v_7_arr[i] = v_11_arr[i] #pull through solar collector
                                v_1_value = 1 #Pull air through the heatsink at 1m/s cuz Python doesn't like dividing by zero
                           
                            #Sets mass flow rate throughout entire system so (rate in = rate out)
                                     
                            m_dot_1 = A_1*v_1_value*rho  
                            m_dot_3 = m_dot_1
                            m_dot_5 = m_dot_1
                            m_dot_7 = A_1*v_7_arr[i]*rho
                            m_dot_9 = m_dot_7

                            T_6 = T_1_multi
                            
                            #State 1 - Ambient air
                            h_1_arr[i] = getEnthalpy(T_1_multi[i])

                            #State 3 - Solar collector just before heatsink
                            Q_dot_solar_2_arr[i] = eff*(q_dot_sun_multi[i]+q_dot_S_multi[i])*A_surface_value #Q_dot = efficiency*heat flux*area

                            #Out_of_energy is left over from an attempt to get the heatsink to turn off when it got below the
                            #desired temperature in order to conserve energy. It failed without a working mixer, but the code 
                            #got buggy when we tried to get rid of it all together, so it's been left in. However, we just made
                            #it so it could never run out of energy, so it's essentially commented out.
                            if out_of_energy == 0:
                                if i < morning_time:
                                    #if early morning 
                                    h_3_arr[i] = (m_dot_1*h_1_arr[i]+Q_dot_solar_2_arr[i])/m_dot_3 #pull ambient air through solar collector
                                elif i > night_time:
                                    h_3_arr[i] = (m_dot_1*h_1_arr[i]+Q_dot_solar_2_arr[i])/m_dot_3 #pull ambient air through solar collector
                                else: #else day or hs ran out of energy
                                    h_3_arr[i] = (m_dot_1*h_5_arr[i-1]+Q_dot_solar_2_arr[i])/m_dot_3 #recirculate hs through solar collector
                            else:
                                if i==0:
                                    h_5_arr[i] = 310 #Sets the first value of each day to something realistic cuz the code can't pull from h_5 since it hasn't been created yet
                                    h_3_arr[i] = (m_dot_1*h_5_arr[i]+Q_dot_solar_2_arr[i])/m_dot_3 #recirculate hs through solar collector #Q_dot = m_dot*(delta h)
                                else:
                                    h_3_arr[i] = (m_dot_1*h_5_arr[i-1]+Q_dot_solar_2_arr[i])/m_dot_3 #Q_dot = m_dot*(delta h)

                            T_3_arr[i] = getTemp(h_3_arr[i])


                            #States 4/5 - Inside and exiting heatsink
                            if i == 0: #If it's the very first hour of the day
                                if days == 0: #If it's the very first day, set it to the initial value
                                    T_hs_arr[i]= T_hs_init_value
                                else: #Otherwise just set it to the value it was the timestep before
                                    T_hs_arr[i]= T_hs_arr[time_steps-1] 
                                
                                Q_dot_hs_arr[i] = m_dot_5*Cp_air*(T_hs_arr[i]-T_3_arr[i])
                                #Q_rad_arr[i] = e*sigma*A_hs*(math.pow((T_hs_arr[i]+273),4)-math.pow((T_sky+273),4))*oneTimeStep
                                Q_convection_arr[i] = 0*(h_c_outside*(A_side_hs+2*A_end_hs)*(T_hs_arr[i]-T_1_multi[i])*oneTimeStep)
                            else:
                                Q_dot_hs_arr[i] = m_dot_5*Cp_air*(T_hs_arr[i-1]-T_3_arr[i])
                                #Q_rad_arr[i] = e*sigma*A_hs*(math.pow((T_hs_arr[i-1]+273),4)-math.pow((T_sky+273),4))*oneTimeStep
                                Q_convection_arr[i] = 0*(h_c_outside*(A_side_hs+2*A_end_hs)*(T_hs_arr[i-1]-T_1_multi[i])*oneTimeStep)

                            Q_hs_arr[i] = Q_dot_hs_arr[i]*oneTimeStep
                            Q_hs_onepass_arr[i] = Q_dot_hs_arr[i]*td_hs/v_1_value
                            Q_gain_arr[i] = 0*(eff*oneTimeStep*alpha)*(((q_dot_E_multi[i]+q_dot_W_multi[i])*A_end_hs)+(q_dot_N_multi[i]*A_side_hs))
                                
                                
                            if i > 0:
                                #I got rid of Q_rad_arr for now (assumed it negligible)
                                T_hs_arr[i] = T_hs_arr[i-1]+(-Q_hs_arr[i]+Q_gain_arr[i]-Q_convection_arr[i])/(m_hs_value*Cp_hs)

                            #h_5_arr[i] = (m_dot_3*h_3_arr[i]+Q_dot_hs_arr[i])/m_dot_5
                            h_5_arr[i] = h_3_arr[i]+Q_hs_onepass_arr[i]/m_air
                            T_5_arr[i] = getTemp(h_5_arr[i])
                            
                            #State 7 - Ambient air directly in to the mixer
                            h_7_arr[i] = getEnthalpy(T_1_multi[i])


                            #State 8 - Solar collector 2
                            Q_dot_solar_8_arr[i] = eff*(q_dot_sun_multi[i]+q_dot_S_multi[i])*A_surface_value

                            #State 9 - Exiting Solar Collector 2
                            h_9_arr[i] = h_7_arr[i]+Q_dot_solar_8_arr[i]/m_dot_9
                            T_9_arr[i] = getTemp(h_9_arr[i])
                        
                                  
                            #State 11 - Mixer, air properties entering the Dryer
                            if out_of_energy == 0:
                                if i < morning_time or i > night_time: #if morning or night and hs is/always been hot enough
                                    m_dot_11_arr[i] = m_dot_5 #pull air to dryer from hs
                                    h_11_arr[i] = (m_dot_5*h_5_arr[i])/m_dot_11_arr[i]
                                else:
                                    m_dot_11_arr[i] = m_dot_9 # pull from solar collector
                                    h_11_arr[i] = (m_dot_9*h_9_arr[i])/m_dot_11_arr[i]
                            else:
                                m_dot_11_arr[i] = m_dot_9 # pull from solar collector
                                h_11_arr[i] = (m_dot_9*h_9_arr[i])/m_dot_11_arr[i]
          
                            T_11_arr[i] = getTemp(h_11_arr[i])
                            #v_11_arr[i] = m_dot_11_arr[i]/(rho*A_11)

                            
                            #State 12 - Inside the Dryer
                            Q_dot_conv_12_arr[i] = h_c_12*A_grape_total*(T_11_arr[i]-T_grapes)

                            if days > 6:
                                time_fill_dryer_arr[i] = volume_air_dryer/(v_11_arr[i]*A_11) #time it takes to fill entire dryer with brand new air
                                MR_arr[i]  = math.pow(2.718281828,(-.937*math.pow((volume_air_dryer/(v_11_arr[i]*A_11)),1.17)))-1 #Moisture Ratio - 1
                                sat_dryer_air_density_arr[i]  = (6.335+.6718*T_11_arr[i]-.020887*math.pow(T_11_arr[i],2)+.00073095*math.pow(T_11_arr[i],3))/1000*.65
                                sat_ambient_air_density_arr[i]  = (6.335+.6718*T_1_multi[i]-.020887*math.pow(T_11_arr[i],2)+.00073095*math.pow(T_1_multi[i],3))/1000*.4

                                
                                evap_rate_arr[i] = (-m_air_dryer/(.8/(sat_dryer_air_density_arr[i] - sat_ambient_air_density_arr[i]))/MR_arr[i])/time_fill_dryer_arr[i]                  

                                if i == 0:
                                    if days == 7: #Allows the system to reach steady state before "putting the grapes in"
                                        m_grapes_arr[i] = m_grapes_init_value
                                        time_to_dry_arr[i] = m_grapes_arr[i]*.8/evap_rate_arr[i]
                                    else:
                                        m_grapes_arr[i]= m_grapes_arr[time_steps-1]
                                        time_to_dry_arr[i] = m_grapes_arr[i]*.8/evap_rate_arr[i]
                                else:
                                    time_to_dry_arr[i] = m_grapes_arr[i-1]*.8/evap_rate_arr[i]
                                    m_grapes_arr[i] = m_grapes_arr[i-1] - evap_rate_arr[i]*oneTimeStep
                                    

                                
                           
                            #State 13 - Exiting the Dryer
                            m_dot_13_arr[i] = m_dot_11_arr[i]
                            h_13_arr[i] = (m_dot_11_arr[i]*h_11_arr[i]-Q_dot_conv_12_arr[i])/m_dot_13_arr[i]
                            T_13_arr[i] = getTemp(h_13_arr[i])


                            if v_11_arr[i] <= .5: #If the velocity has slowed down to it's lower limit
                                KeepGoing = 0 #Record the timestep and move on
                            elif T_11_arr[i] < min_temp: 
                                KeepGoing = 1 #loop again with slower air temp 
                            else:
                                KeepGoing = 0

                        #Commented out so the system will keep running even after the heatsink is below the desired temperature
                        '''if out_of_energy == 0:
                            if T_5_arr[i] > min_temp:
                                out_of_energy = 0
                            else:
                                out_of_energy = 1
                        else:
                            if i == night_time:
                                out_of_energy = 0'''
                        
                                   
                                    
                            #End while loop

                    #Print Statements
                    #the format is called CSV comma separated values
                    #the output can be copied and pasted into Excel
                    #first the column headers separated by commas
                    if days > 6: #Only prints out the data once the grapes have been put in after the system reaches steady state
                        if raisins == 0: #Stops printing at the end of the day when the grapes reach 25% of their original mass
                            if print_headers_once == 0:
                                print_headers_once=1
                                #print("Iteration,",end='')
                                print("Day,",end='')
                                print("Hour,",end='')
                                #print("T_hs_init,",end='')
                                print("%Full,",end='')
                                #print("A_surface,",end='')
                                #print("v_1,", end='')
                                #print("v_7,", end='')
                                print("v_11,", end='')
                                #print("h_1,",end='')
                                #print("Q_dot_solar_2,",end='')
                                #print("h_3,",end='')
                                #print("T_3,",end='')
                                #print("Q_dot_hs,",end='')
                                #print("Q_hs,",end='')
                                #print("Q_rad,",end='')
                                #print("Q_gain,",end='')
                                #print("Q_convection,",end='')
                                print("T_hs,",end='')
                                print("T_5,",end='')
                                #print("h_5,",end='')
                                #print("h_7,",end='')
                                #print("Q_dot_solar_8,",end='')
                                #print("h_9,",end='')
                                print("T_9,",end='')
                                #print("m_dot_11,",end='')
                                #print("h_11,",end='')
                                print("T_11,",end='')
                                #print("Evap rate,", end='')
                                #print("Time to Dry,", end = '')
                                print("Initial grape mass,", end = '')
                                print("Tray number,", end = '')
                                print("Grape mass left,", end = '')
                                #print("Q_dot_conv_12,",end='')
                                #print("h_13,",end='')
                                #print("T_13")
                                print('')

                            #now print the values for each hour, in a single row, in the same order as the headers, separated by commas
                            
                            for i in range(time_steps):
                                #print(iteration, end=',')
                                print(days, end=',')
                                print("%.2f" % round(i*oneTimeStep/secs_in_hour,2), end=',')
                                #print("%.1f" % round(T_hs_init_value,2), end=',')
                                print("%.1f" % round(m_hs_value/m_full_container*100,2), end=',')
                                #print("%.1f" % round(A_surface_value,2), end=',')
                                #print("%.2f" % round(v_1_value,2), end=',')
                                #print("%.2f" % round(v_7_arr[i],2), end=',')
                                print("%.2f" % round(v_11_arr[i],2), end=',')
                                #print("%.1f" % round(h_1_arr[i],2), end=',')
                                #print("%.1f" % round(Q_dot_solar_2_arr[i],2), end=',')
                                #print("%.1f" % round(h_3_arr[i],2), end=',')
                                #print("%.1f" % round(T_3_arr[i],2), end=',')
                                #print("%.1f" % T_3_arr[i], end=',')
                                #print("%.2f" % round(Q_dot_hs_arr[i],2), end=',')
                                #print("%.1f" % round(Q_hs_arr[i],2), end=',')
                                #print("%.1f" % round(Q_rad_arr[i],2), end=',')
                                #print("%.3f" % round(Q_gain_arr[i],3), end=',')
                                #print("%.2f" % round(Q_convection_arr[i],2), end=',')
                                print("%.2f" % round(T_hs_arr[i],2), end=',')
                                print("%.2f" % round(T_5_arr[i],2), end=',')
                                #print("%.2f" % round(h_5_arr[i],2), end=',')
                                #print("%.2f" % round(h_7_arr[i],2), end=',')
                                #print("%.2f" % round(Q_dot_solar_8_arr[i],2), end=',')
                                #print("%.2f" % round(h_9_arr[i],2), end=',')
                                print("%.2f" % round(T_9_arr[i],2), end=',')
                                #print("%.2f" % round(m_dot_11_arr[i],2), end=',')
                                #print("%.2f" % round(h_11_arr[i],2), end=',')
                                print("%.2f" % round(T_11_arr[i],2), end=',')
                                #print("%.5f" % round(evap_rate_arr[i],5), end=',')
                                #print("%.5f" % round(time_to_dry_arr[i],5), end=',')
                                print("%.5f" % round(m_grapes_init_value,5), end=',')
                                print("%.2f" % round(m_grapes_init_value/334,2), end=',')
                                print("%.2f" % round(m_grapes_arr[i],2), end=',')
                                #print("%.2f" % round(Q_dot_conv_12_arr[i],2), end=',')
                                #print("%.2f" % round(h_13_arr[i],2), end=',')
                                #print("%.2f" % round(T_13_arr[i],2), end=',')
                                print('')
                       
                        sys.stdout.flush() #Prevents the last few lines of data from being cut off. Not sure why that happened, but this is necessary
                        iteration= iteration +1
                        if days > 6:
                            if m_grapes_arr[i] < .25*m_grapes_init_value:
                                    raisins = 1







