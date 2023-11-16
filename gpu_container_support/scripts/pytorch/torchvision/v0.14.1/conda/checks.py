import torch
import torchvision

if torch.cuda.is_available():
    device = torch.device("cuda")
    print("GPU is available")
else:
    device = torch.device("cpu")
    print("GPU is NOT available")

model = torchvision.models.resnet18(pretrained=True)
model = model.to(device)
input_data = torch.randn(1, 3, 224, 224).to(device)
output = model(input_data)

print(output)