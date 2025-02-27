#' @name OSTA.data
#' @title Datasets used in OSTA
#' @aliases OSTA.data_list OSTA.data_load
#' 
#' @param id character string; dataset identifier
#'   (see \code{\link{OSTA.data_list}} for valid options)
#' @param url character string; an OSF identifier
#'   (passed to \code{\link[osfr]{osf_retrieve_node}})
#' @param bfc \code{\link[BiocFileCache]{BiocFileCache}}
#'   instance giving the location of files stored on disk
#' @param pol,mol logical scalar; specifies whether or not 
#'   to retrieve boundaries and molecules, respectively
#' @param bin character string; the bin size to load
#'   (ignored unless reading in a Visium HD dataset)
#' 
#' @details The following datasets are currently available:\itemize{
#' \item{Janesick \emph{et al.}:
#'   Visium, Visium HD, Xenium and Chromium
#'   data on human colorectal cancer;
#'   source: \href{https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE243280}{GSE243280}
#'   source chromium h5: \href{https://www.10xgenomics.com/products/xenium-in-situ/preview-dataset-human-breast}{10x Genomics}}
#' \item{Oliveira \emph{et al.}:
#'   Visium, Xenium and Chromium
#'   data on human breast cancer;
#'   source: \href{https://www.10xgenomics.com/products/visium-hd-spatial-gene-expression/dataset-human-crc}{10x Genomics}}
#' \item{1k-plex CosMx data on 2 mouse brain sections
#'   (coronal hippocampus and cortex, coronal hemisphere)
#'   source: \href{https://nanostring.com/products/cosmx-spatial-molecular-imager/ffpe-dataset/cosmx-smi-mouse-brain-ffpe-dataset}{NanoString}}
#' \item{6k-plex CosMx data on human brain (frontal cortex);
#'   source: \href{https://nanostring.com/products/cosmx-spatial-molecular-imager/ffpe-dataset/human-frontal-cortex-ffpe-dataset}{NanoString}}}
#' 
#' @references 
#' Oliveira \emph{et al.} 
#' Characterization of immune cell populations in the tumor 
#' microenvironment of colorectal cancer using high definition 
#' spatial profiling. \emph{bioRxiv} 2024.06.04.597233 (2024).
#' 
#' Janesick \emph{et al.} 
#' High resolution mapping of the tumor microenvironment 
#' using integrated single-cell, spatial and in situ analysis.
#' \emph{Nature Communications} 14:8353 (2023).
#' 
#' @returns\itemize{
#' \item{\code{OSTA.data_list} 
#'   returns a character vector of 
#'   currently available datasets}
#' \item{\code{OSTA.data_load} 
#'   returns a character string;
#'   the path to a Zip archive},
#' \item{\code{OSTA.data_read}
#'   returns an object of class
#'   \code{SpatialExperiment}}}
#' 
#' @examples
#' # view available datasets
#' OSTA.data_list()
#' 
#' # retrieve 10x Xenium data from Oliveira et al.
#' id <- "Xenium_HumanColon_Oliveira"
#' pa <- OSTA.data_load(id)
#' 
#' # unpack & view contents
#' td <- tempfile()
#' dir.create(td)
#' unzip(pa, exdir=td)
#' list.files(td)
#' 
#' # read into 'SpatialExperiment'
#' library(SpatialExperimentIO)
#' (spe <- readXeniumSXE(td))
#' 
#' # load & read directly
#' (spe <- OSTA.data_read(id))
NULL

#' @importFrom osfr osf_retrieve_node osf_ls_files
#' @rdname OSTA.data
#' @export
OSTA.data_list <- \(url="https://osf.io/5n4q3") {
    osf <- osf_retrieve_node(url)
    sort(osf_ls_files(osf, n_max=Inf)$name)
}

#' @importFrom utils zip
#' @importFrom BiocFileCache BiocFileCache bfcquery bfcadd
#' @importFrom osfr osf_retrieve_node osf_ls_files osf_download
#' @rdname OSTA.data
#' @export
OSTA.data_load <- \(id, 
    bfc=BiocFileCache(), 
    url="https://osf.io/5n4q3",
    pol=TRUE, mol=TRUE) {
    stopifnot(
        is.character(id), length(id) == 1,
        is.logical(pol), length(pol) == 1,
        is.logical(mol), length(mol) == 1)
    # verify 'id' with informative error if not
    id <- match.arg(id, OSTA.data_list(url))
    # check if already cached
    q <- bfcquery(bfc, id)
    n <- nrow(q)
    i <- 1
    if (n > 1) {
        message("multiple 'id' hits; using last")
        i <- n
    } else if (n > 0) {
        return(q$rpath[i])
    }
    # retrieve, zip, cache & return path
    no <- osf_retrieve_node(url)
    df <- osf_ls_files(no, id)
    if (!pol) df <- df[!grepl("bound|poly", df$name), ]
    if (!mol) df <- df[!grepl("tx|scripts", df$name), ]
    dir.create(td <- tempfile())
    osf_download(df, td, recurse=TRUE)
    wd <- getwd()
    setwd(td)
    zip(fnm <- paste0(id, ".zip"), dir())
    bfcadd(bfc, fnm, fpath=file.path(".", fnm))
}

#' @importFrom utils unzip
#' @rdname OSTA.data
#' @export
OSTA.data_read <- \(id,
    bfc=BiocFileCache(), 
    url="https://osf.io/5n4q3",
    pol=TRUE, mol=TRUE, 
    bin=c("008", "016")) {
    bin <- match.arg(bin)
    args <- as.list(environment())
    args$bin <- NULL
    pa <- do.call(OSTA.data_load, args)
    dir.create(td <- tempfile())
    unzip(pa, exdir=td)
    typ <- c("Chromium", "CosMx", "Visium", "VisiumHD", "Xenium")
    pat <- ifelse(typ == "Visium", paste0(typ, "_"), typ)
    typ <- typ[which(vapply(pat, \(.) grepl(., id), logical(1)))]
    switch(typ,
        Chromium=.chr(td),
        CosMx=.cos(td),
        Xenium=.xen(td),
        .vis(td, typ, bin))
}

.dep <- \(x) {
    if (!requireNamespace(x, quietly=TRUE))
        stop("missing dependency; install using",
            " BiocManager::install('", x, "')")
}
.chr <- \(x) {
    .dep("DropletUtils")
    .dep("SummarizedExperiment")
    fs <- list.files(x, full.names=TRUE)
    h5 <- grep("h5$", fs, value=TRUE)
    sce <- DropletUtils::read10xCounts(h5)
    csv <- grep("csv$", fs, value=TRUE)
    if (length(csv)) {
        get_cd <- SummarizedExperiment::colData
        set_cd <- SummarizedExperiment::`colData<-`
        df <- read.csv(csv)
        i <- match(sce$Barcode, df$Barcode)
        j <- setdiff(names(df), names(get_cd(sce)))
        cd <- get_cd(sce); cd[j] <- df[i, j]
        sce <- set_cd(sce, value=cd)
    }
    sce
}
.cos <- \(x) {
    .dep("SpatialExperimentIO")
    fun <- SpatialExperimentIO::readCosmxSXE
    pol <- length(list.files(x, "yg"))
    mol <- length(list.files(x, "tx"))
    spe <- fun(x, addTx=mol, addPolygon=pol)
    csv <- list.files(x, "anno", full.names=TRUE)
    if (length(csv)) {
        df <- read.csv(csv)
        i <- paste(df$fov, df$cell_ID, sep=";")
        j <- paste(spe$fov, spe$cell_ID, sep=";")
        spe$Annotation <- df$Annotation[match(j, i)]
    }
    spe
}
#' @importFrom utils getFromNamespace
.vis <- \(x, typ, bin) {
    .dep("VisiumIO")
    fun <- getFromNamespace(paste0("TENx", typ), "VisiumIO")
    arg <- list(spacerangerOut=x, images="lowres", format="h5")
    if (typ == "VisiumHD") arg$bin <- bin
    VisiumIO::import(do.call(fun, arg))
}
.xen <- \(x) {
    .dep("XeniumIO")
    spe <- XeniumIO::import(XeniumIO::TENxXenium(xeniumOut=x, format="h5"))
    csv <- list.files(x, "anno", full.names=TRUE)
    if (length(csv)) {
        df <- read.csv(csv)
        i <- match(spe$cell_id, df[[1]])
        spe$Annotation <- df$Annotation[i]
    }
    spe
}

