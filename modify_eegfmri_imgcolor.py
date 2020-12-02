
# coding: utf-8

# In[1]:


file = "D:/eeg_fmri/ICA_1027/graph/brain42_51_Sagittal.tiff"
from PIL import Image
image = Image.open(file)


# In[2]:


print (image.size)
print (image.getpixel((51,58)))


# In[3]:


width = image.size[0]#长度
height = image.size[1]#宽度
for i in range(0,width):#遍历所有长度的点
    for j in range(0,height):#遍历所有宽度的点
        data = (image.getpixel((i,j)))#打印该图片的所有点
        # print (data)#打印每个像素点的颜色RGBA的值(r,g,b,alpha)
        # print (data[0])#打印RGBA的r值
        if (data[0]==0 and data[1]==0 and data[2]==0):#RGBA的rgb等于0
            image.putpixel((i,j),(255,255,255,255))#第四个是透明度

#img = image.convert("RGB")#把图片强制转成RGB
image.save("D:/eeg_fmri/ICA_1027/graph/modified_brain42_51.tiff")#保存修改像素点后的图片

