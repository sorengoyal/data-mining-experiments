norm_vec <- function(x) sqrt(sum(x^2))

irisScale = function(source_data, data) {
  data_col_names <- colnames(source_data)
  source_data <- source_data[, 1:length(data_col_names)-1]
  means <- NULL
  for(i in 1:ncol(source_data)) {
    means[i] <- mean(source_data[,i])  
  }
  sdev <- NULL
  for(i in 1:ncol(source_data)){
    sdev[i] <- sd(source_data[,i])
  }
  output = data.frame(matrix(ncol = ncol(data), nrow = nrow(data)))
  for(j in 1:nrow(data)){
    output[j,] <- (data[j,] - means)/sdev
  }
  return(output)
}

getIrisPrediction = function(indices, labels){
  classCount = c(0,0,0)
  names(classCount) = c("Iris-setosa", "Iris-virginica","Iris-versicolor")
  for(i in 1:length(indices)){
    classCount[labels[indices[i]]] = classCount[labels[indices[i]]] + 1
  }
  maxnum = 0
  maxindex = 0
  for(i in 1:3){
    if(maxnum < classCount[i]){
      maxnum = classCount[i]
      maxindex = i
    }
  }
  pred = c(maxindex, classCount[maxindex]/sum(classCount))
  names(pred) = c("class", "probablity")
  return(pred)
}

irisKnn = function(k, train_data, train_labels, test_data, test_labels){
  output = data.frame(matrix(nrow = nrow(test_data), ncol = 4))
  for(i in 1:nrow(test_data)){
    dist.euclidean <- vector(mode = "numeric", length = nrow(train_data))
    for(j in 1:nrow(train_data)){
      #dist.euclidean[j] = sum((train_data[j, ] - test_data[i,])^2)
      dist.euclidean[j] = acos(sum(train_data[j, ] * test_data[i,])/norm_vec(train_data[j,])/norm_vec(test_data[i,]))
      }
    dist.sorted = sort(dist.euclidean, index.return = TRUE)
    prediction = getIrisPrediction(dist.sorted$ix[1:k], train_labels)
    output[i,1] = i
    output[i,2] = test_labels[i]
    output[i,3] = prediction["class"] 
    output[i,4] = prediction["probablity"]
  }
  names(output) = c("Transaction_ID", "Actual_Label", "Predicted_Label", "Confidence")
  return(output)
}

computePerformance = function(predictions){
  correct = 0
  incorrect = 0
  classification_confidence = 0
  for(i in 1:nrow(predictions)){
    if(predictions$Actual_Label[i] == predictions$Predicted_Label[i]){
      correct = correct + 1
      classification_confidence = classification_confidence + predictions$Confidence[i]
    }
    else
      incorrect = incorrect + 1
  }
  print(paste("Classification Rate:", correct/nrow(predictions),"   Classification Confidence:", classification_confidence/correct))
  print(paste("Misclassification Rate:", incorrect/nrow(predictions)))
}

computeConfusionMatrix = function(predictions){
  #(i,j) = (actual, predicted)
  confusion_mat = matrix(data = c(0,0,0,0,0,0,0,0,0), nrow = 3, ncol = 3)
  for(i in 1:nrow(predictions)){
    alabel = predictions$Actual_Label[i]
    plabel = predictions$Predicted_Label[i]
    confusion_mat[alabel, plabel] = confusion_mat[alabel, plabel] + 1
  }
  return(confusion_mat)
}