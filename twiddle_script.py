import math

zeros_filename = "zeros.txt"
real_filename = "rom_r_init.txt"
imag_filename = "rom_i_init.txt"
sim_folder = "simulation/modelsim/"
real_filename_sim = sim_folder + real_filename
imag_filename_sim = sim_folder + imag_filename
num_samples = 512
data_width = 22
multiplier = 2**(data_width-1);

def main():
    f_zeros = open(zeros_filename, "w")
    f_real = open(real_filename, "w")
    f_imag = open(imag_filename, "w")
    f_real_sim = open(real_filename_sim, "w")
    f_imag_sim = open(imag_filename_sim, "w")
    for k in range(int(num_samples/2)):
        real = math.cos(2*math.pi*k/num_samples) * multiplier
        imag = -math.sin(2*math.pi*k/num_samples) * multiplier
        real = int(round(real))
        imag = int(round(imag))
        if real < 0:
            real = real + 2 ** data_width
        elif real == multiplier:
            real = multiplier - 1

        if imag < 0:
            imag = imag + 2 ** data_width

        if imag == multiplier:
            imag = multiplier + 1
        
        f_zeros.write(format(0, "0{}b".format(data_width)) + "\n")
        f_real.write(format(real, "0{}b".format(data_width)) + "\n")
        f_real_sim.write(format(real, "0{}b".format(data_width)) + "\n")
        f_imag.write(format(imag, "0{}b".format(data_width)) + "\n")
        f_imag_sim.write(format(imag, "0{}b".format(data_width)) + "\n")


if __name__ == "__main__":
    main()
