




def TB_PWM_DAC():
    # Init module signals & constants
    clk, reset, pwm_out = [signal(False) for _ in range(2)]
    width = np.random.randint(4, 10) # not logic vector
    voltage = intbv(np.random.randint(0, (2**width-1)))[width:]
    pwm_out  = signal(False)
    pwm_type = 'standard'

    # Init module
    dac = PWM_DAC(clk, reset, voltage, pwm_out, width=width, pwm_type=pwm_type)

    # Testbench signals & constants
    HALF_CLK_PERIOD = delay(10)


    @always(HALF_CLK_PERIOD)
    def clk_process():
        clk.next = not clk

    @instance
    def stimulus():
        pass

    @instance
    def monitor():
        print('Running PWM_DAC testbench')
        



