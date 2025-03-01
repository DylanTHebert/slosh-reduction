import numpy as np
import cv2
import os
import pdb
import scipy
import matplotlib.pyplot as plt
from matplotlib import cm

font = {'family' : 'normal',
        'weight' : 'bold',
        'size'   : 14}

plt.rc('font', **font)

working_dir = r"C:\Users\dylan\OneDrive - Georgia Institute of Technology\GaTech\MSME yr1\Adv. controls\final_proj\1-5 testing"
save_dir = r"C:\Users\dylan\OneDrive - Georgia Institute of Technology\GaTech\MSME yr1\Adv. controls\final_proj\images"

def load_mp4_as_np(file_name):
    cap = cv2.VideoCapture(file_name)
    frameCount = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    frameWidth = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frameHeight = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    buf = np.empty((frameCount, frameHeight, frameWidth, 3), np.dtype('uint8'))

    fc = 0
    ret = True

    while (fc < frameCount  and ret):
        ret, buf[fc] = cap.read()
        fc += 1

    cap.release()
    return buf
    # cv2.namedWindow('frame 10')
    # cv2.imshow('frame 10', buf[9])
    # cv2.waitKey(0)

files = os.listdir(working_dir)
threshold = 40

def create_Gaussian_kernel_1D(ksize: int, sigma: int) -> np.ndarray:
    """Create a 1D Gaussian kernel using the specified filter size and standard deviation.
    
    The kernel should have:
    - shape (k,1)
    - mean = floor (ksize / 2)
    - values that sum to 1
    
    Args:
        ksize: length of kernel
        sigma: standard deviation of Gaussian distribution
    
    Returns:
        kernel: 1d column vector of shape (k,1)
    """
    #create vector from formula shifted by ksize/2, normalize
    kernel = np.exp( [-1*(1/(2*(sigma**2)))*((i-(ksize//2))**2) for i in range(ksize)] )
    kernel = (1/np.sum(kernel))*(kernel)
    #kernel = kernel.reshape([ksize,1])
    h_center = ksize // 2
    return kernel

kernel = 5
for i, file in enumerate(files):
    #read it in, 
    vid = load_mp4_as_np(os.path.join(working_dir,file))
    gray_image_stack = np.zeros((vid.shape[0], 645, 960), dtype=np.uint8)
    gradient = np.zeros((vid.shape[0], 644, 960), dtype=np.uint8)
    edge_vector = np.zeros((vid.shape[0],960))
    edge_vector_smooth = np.zeros((vid.shape[0],960+1-kernel))
    file_pre = str(os.path.splitext(file)[0])
    print(file)
    # pdb.set_trace()
    # fourcc = cv2.VideoWriter_fourcc('m', 'p', '4', 'v')
    #out = cv2.VideoWriter(file_pre+'.mp4',fourcc, 28, (645,960))
    for frame in range(vid.shape[0]):
        #find the crop lines, hor line
        #top pixel 275
        # vid[i,275,:,1] = 255
        #bot pixel 920
        # vid[i,920,:,1] = 255
        #left pixel 650
        # vid[i,:,650,1] = 255
        #right pixel
        # vid[i,:,1610,1] = 255
        # cropped = vid[i,275:920,650:1610,:]
        #grayscale,grab red, image
        gray_image_stack[frame,:,:] = cv2.cvtColor(vid[frame,275:920,650:1610,:], cv2.COLOR_BGR2GRAY) #vid[i,:,:,2]
        # cv2.imshow("image {}".format(i), gray_image_stack[i,:,:])
        # cv2.waitKey(0)
        #threshold
        _, gray_image_stack[frame,:,:] = cv2.threshold(gray_image_stack[frame,:,:], threshold, 255, cv2.THRESH_BINARY_INV)
        gradient[frame,:,:] = np.diff(gray_image_stack[frame,:,:],axis=0)
        #gradient[i,:,:][gradient[i,:,:] == 1] = 255 #grab only positive gradients
        #out.write(gray_image_stack[i])sobel f
        #try an argmax to pull the pixel location out, then I'm gonna try to smooth the resulting vector of pixel height to take out the noise
        edge_vector[frame,:] = 644 - np.argmax(gradient[frame,:,:], axis=0)
        std = np.std(edge_vector[frame,:])
        #quick and dirty smoothing
        for j in range(edge_vector.shape[1]-1):
            if (np.abs(edge_vector[frame,j+1] - edge_vector[frame,j]) > 25):
                #replace it with the previous
                edge_vector[frame,j+1] = edge_vector[frame,j]
        #edge_vector_ssmooth[i, :] = np.convolve(edge_vector[i,:], np.ones(3)/3, mode='valid')
        # edge_vector_smooth[i,:] = np.convolve(edge_vector[i,:], create_Gaussian_kernel_1D(kernel, np.std(edge_vector[i,:])), "valid")
        # plt.plot([i for i in range(edge_vector.shape[1])],edge_vector[i,:])
        # plt.xlim([0,644])
        # plt.ylim([0,960])
        # plt.show()
        # cv2.imshow("image {}".format(i), gradient[i,:,:])
        # cv2.waitKey(0)
        #threshold the image
    #out.release()
    #plot in 3D 
    edge_vector = edge_vector[90:-1,:]
    fig, ax = plt.subplots(subplot_kw={"projection": "3d"})
    #x is the width of the image
    Y = [i*(1/25) for i in range(edge_vector.shape[0])]
    #y time axis
    X = [i for i in range(edge_vector.shape[1])]
    X, Y = np.meshgrid(X, Y)
    #z is the height, or edge_vector values
    Z = edge_vector
    surf = ax.plot_surface(X, Y, Z, cmap=cm.coolwarm,
                       linewidth=0, antialiased=False)
    ax.set_xlabel('image width')
    ax.set_ylabel('Time')
    ax.set_zlabel('water level')
    plt.tight_layout()
    ax.axes.set_ylim3d(bottom=0, top=edge_vector.shape[0]*(1/30)) 
    ax.axes.set_xlim3d(left=0, right=edge_vector.shape[1]) 
    ax.axes.set_zlim3d(bottom=0, top=960)
    plt.tight_layout()
    plt.show()
    plt.savefig(os.path.join(save_dir,os.path.splitext(file)[0]+'1d.png'))
    pdb.set_trace()
    plt.close()
    one_edge = edge_vector[:,-1]
    plt.plot([i for i in range(edge_vector.shape[0])], one_edge)
    plt.xlim([0,edge_vector.shape[0]])
    plt.ylim([0,960])
    plt.tight_layout()
    plt.savefig(os.path.join(save_dir,os.path.splitext(file)[0]+"1d.png"))
    #save 3d plot