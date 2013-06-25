Sys.setlocale(category="LC_TIME", "C")

log2 <- read.table("access.extend.log-20130527", quote="\"")

#convert timestamp
log2$V2 <- as.POSIXct(strptime(substr(paste(log2$V4, log2$V5), 2, 27), format="%d/%b/%Y:%H:%M:%S %z"))
log2$V5 <- NULL
log2$V6 <- as.character(log2$V6)
log2[log2$V6=="-", "V6"] <- "- - -" #Must be two spaces in this field
log2$V6 <- as.factor(log2$V6)

urlParts <- strsplit(as.character(log2$V6), " ")
urlParts <- matrix(unlist(urlParts), ncol=3, byrow=TRUE)
log2$V3 <- urlParts[,1]
log2$V4 <- urlParts[,2]
log2$V6 <- NULL

#Adjust column names
names(log2) <- c("ip", "timestamp", "method", "url", "code", "bytes", "referref", "useragent", "time", "host", "internalip")
log2$user.action <- NA

#Convert time
log2$time <- as.factor(ifelse(log2$time=="-", "0", as.character(log2$time)))

log2$is.server.error <- FALSE
log2[log2$code >= 500, ]$is.server.error <- TRUE

fill.user.action <- function(logData) {
  static.resources <- c('GET', '/app/resources/', 'static.resources')
  static.respub <- c('GET', '/app/respub/', 'static.respub')
  #options <- c('OPTIONS', NA, 'options')
  rest.get.asset <- c('GET', '/app/rest/html5/asset/', 'rest.get.asset')
  rest.keep.alive <- c('PUT', '/app/rest/html5/user/\\d+/keepAlive/', 'rest.keep.alive')
  flex.amf <- c('POST', '/app/seam/resource/amf', 'flex.amf')
  login <- c('POST', '/app/j_security_check', 'login')
  javax.faces.resources <- c('GET', '/app/javax.faces.resource/', 'javax.faces.resources')
  javax.faces.resources2 <- c('GET', '/app/require/javax.faces.resource', 'javax.faces.resources')
  rest.tracking <- c('GET', '/app/rest/tracking', 'rest.tracking')
  cms <- c('GET', '/wp-content/', 'cms')
  preview.screen <- c('GET', '/app/view/', 'preview.screen')
  preview.assets <- c('GET', '/app/views/', 'preview.assets')
  preview.mobile.frame <- c('GET', '/app/mobile-frame', 'preview.mobile.frame')
  rest.asset.rename <- c('PUT', '/app/rest/html5/asset/\\d+/rename', 'rest.asset.rename')
  rest.log <- c('POST', '/app/rest/html5/log', 'rest.log')
  
  rules <- list(static.resources, static.respub, rest.get.asset,
             rest.keep.alive, flex.amf, login, javax.faces.resources,
             javax.faces.resources2, rest.tracking, cms, preview.screen,
             preview.assets, preview.mobile.frame, rest.asset.rename,
             rest.log)
  
  for(rule in rules) {
    s.method <- rule[1]
    s.urlPattern <- rule[2]
    s.user.action <- rule[3]
    print(paste("Settings user action:", s.method, s.urlPattern, s.user.action))
    
    selected.indexes <- (logData$method==s.method & (grepl(s.urlPattern, logData$url, perl=TRUE)==1))
    #print(table(selected.indexes))
    if (length(table(selected.indexes))==2) { #found some entries
      logData[selected.indexes, ]$user.action <- s.user.action
    }
    
  }
  
  logData[logData$url == "-", ]$user.action <- "aborted"
  
  return(logData)
}
