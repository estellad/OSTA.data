# ---------------------------
# Create metadata spreadsheet
# ---------------------------

base <- data.frame(
  BiocVersion="3.21",
  Genome=NA,
  SourceType="Zip",
  SourceVersion=NA_character_,
  TaxonomyId=NA_character_,
  Coordinate_1_based=TRUE,
  Maintainer="Yixing E. Dong <estelladong729@gmail.com>",
  RDataClass=NA_character_,
  DispatchClass="Zip",
  RDataPath="OSTA.data")

## Oliveira
url_oli <- "https://www.10xgenomics.com/products/visium-hd-spatial-gene-expression/dataset-human-crc"
cc4 <- "Creative Commons Attribution 4.0 International (CC BY 4.0)"

oli_chm <- data.frame(base,
    SourceUrl=url_oli,
    Species="Homo sapiens",
    DataProvider="10x Genomics",
    Tags="Oliveira:Chromium",
    Title="Chromium_HumanColon_Oliveira",
    Description="10x Genomics Chromium data on human colorecal cancer",
    Licence=cc4)

oli_vis <- data.frame(base,
    SourceUrl=url_oli,
    Species="Homo sapiens",
    DataProvider="10x Genomics",
    Tags="Oliveira:Visium",
    Title="Visium_HumanColon_Oliveira",
    Description="10x Genomics Visium data on human colorecal cancer",
    Licence=cc4)

oli_vhd <- data.frame(base,
    SourceUrl=url_oli,
    Species="Homo sapiens",
    DataProvider="10x Genomics",
    Tags="Oliveira:VisiumHD",
    Title="VisiumHD_HumanColon_Oliveira",
    Description="10x Genomics VisiumHD data on human colorecal cancer",
    Licence=cc4)

oli_xem <- data.frame(base,
    SourceUrl=url_oli,
    Species="Homo sapiens",
    DataProvider="10x Genomics",
    Tags="Oliveira:Xenium",
    Title="Xenium_HumanColon_Oliveira",
    Description="10x Genomics Xenium data on human colorecal cancer",
    Licence=cc4)


## Janesick
jan_chm <- data.frame(base,
    SourceUrl="https://www.10xgenomics.com/products/xenium-in-situ/preview-dataset-human-breast",
    Species="Homo sapiens",
    DataProvider="10x Genomics",
    Tags="Janesick:Chromium",
    Title="Chromium_HumanBreast_Janesick",
    Description="10x Genomics Chromium data on human breast cancer",
    Licence=NA_character_)

jan_vis <- data.frame(base,
    SourceUrl="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM7782699",
    Species="Homo sapiens",
    DataProvider="10x Genomics",
    Tags="Janesick:Visium",
    Title="Visium_HumanBreast_Janesick",
    Description="10x Genomics Visium data on human breast cancer",
    Licence=NA_character_)

jan_xem <- data.frame(base,
    SourceUrl = "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM7780153",
    Species="Homo sapiens",
    DataProvider="10x Genomics",
    Tags="Janesick:Xenium",
    Title="Xenium_HumanBreast1_Janesick",
    Description="10x Genomics Xenium data on human breast cancer",
    Licence=NA_character_)


## CosMx 
url_cosmouse <- "https://nanostring.com/products/cosmx-spatial-molecular-imager/ffpe-dataset/cosmx-smi-mouse-brain-ffpe-dataset/"
pdf <- "see 'Bruker-DataLicence.pdf' included in the Zip archive"

cos_mb1 <- data.frame(base,
    SourceUrl=url_cosmouse,
    Species="Mus musculus",
    DataProvider="Nanostring",
    Tags="CosMx1k:MouseBrain1",
    Title="CosMx1k_MouseBrain1",
    Description="NanoString CosMx data (1k-plex) on mouse brain coronal hippocampus and cortex - quarter",
    Licence=pdf)

cos_mb2 <- data.frame(base,
    SourceUrl=url_cosmouse,
    Species="Mus musculus",
    DataProvider="Nanostring",
    Tags="CosMx1k:MouseBrain2",
    Title="CosMx1k_MouseBrain2",
    Description="NanoString CosMx data (1k-plex) on mouse brain coronal hemisphere - half",
    Licence=pdf)

cos_hb <- data.frame(base,
    SourceUrl="https://nanostring.com/products/cosmx-spatial-molecular-imager/ffpe-dataset/human-frontal-cortex-ffpe-dataset/",
    Species="Homo sapiens",
    DataProvider="Nanostring",
    Tags="CosMx6k:HumanBrain",
    Title="CosMx6k_HumanBrain",
    Description="NanoString CosMx data (6k-plex) on human frontal cortex",
    Licence=pdf)

(df <- rbind(
  oli_chm, oli_vis, oli_vhd, oli_xem,
  jan_chm, jan_vis, jan_xem,
  cos_mb1, cos_mb2, cos_hb))

write.csv(df, file.path("inst", "extdata", "metadata.csv"))
md <- ExperimentHubData::makeExperimentHubMetadata(".")
