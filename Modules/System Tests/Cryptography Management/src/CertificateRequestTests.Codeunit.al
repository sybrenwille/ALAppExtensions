codeunit 132590 "CertificateRequestTests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;

    [Test]
    procedure CreateCertificateSigningRequest()
    var
        CertSigningRequest: Codeunit CertificateRequest;
        KeyXml: XmlDocument;
        Root: XmlElement;
        Node: XmlNode;
        KeyXmlText, SigningRequestPem : Text;
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        Oids: List of [Text];
        BCRTok: Label '-----BEGIN CERTIFICATE REQUEST-----';
        ECRTok: Label '-----END CERTIFICATE REQUEST-----';
    begin
        CertSigningRequest.InitializeRSA(2048, true, KeyXmlText);

        Assert.IsTrue(XmlDocument.ReadFrom(KeyXmlText, KeyXml), 'RSA key is not valid xml data.');
        Assert.IsTrue(KeyXml.GetRoot(Root), 'Could not get Root element of key.');

        Assert.IsTrue(Root.SelectSingleNode('Modulus', Node), 'Could not find <Modulus> in key.');
        Assert.IsTrue(Root.SelectSingleNode('DQ', Node), 'Could not find <DQ> in key.');

        CertSigningRequest.InitializeCertificateRequestUsingRSA(
            GetSubjectName(), HashAlgorithm::SHA256, RSASignaturePadding::Pkcs1);

        CertSigningRequest.AddX509BasicConstraintToCertificateRequest(false, false, 0, true);

        CertSigningRequest.AddX509KeyUsageToCertificateRequest(16 + 128, false);

        Oids.Add('1.3.6.1.5.5.7.3.2');
        CertSigningRequest.AddX509EnhancedKeyUsageToCertificateRequest(Oids, false);

        CertSigningRequest.CreateSigningRequest(SigningRequestPem);

        Assert.AreEqual(BCRTok, SigningRequestPem.Substring(1, StrLen(BCRTok)), 'Invalid PEM certificate signing request.');
        Assert.AreEqual(ECRTok, SigningRequestPem.Substring(StrLen(SigningRequestPem) - StrLen(ECRTok) + 1, StrLen(ECRTok)), 'Invalid PEM certificate signing request.');

        SigningRequestPem := SigningRequestPem.Substring(StrLen(BCRTok) + 1).Trim();
        Assert.AreEqual('MII', SigningRequestPem.Substring(1, 3), 'Invalid PEM certificate signing request.');
    end;


    [Test]
    procedure CreateSelfSignedCertificate()
    var
        CertSigningRequest: Codeunit CertificateRequest;
        X509Certificate2: Codeunit X509Certificate2;
        KeyXmlText, CertBase64Value, Subject : Text;
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        X509ContentType: Enum "X509 Content Type";
        SubjectName: Text;
    begin
        CertSigningRequest.InitializeRSA(2048, true, KeyXmlText);

        SubjectName := GetSubjectName();

        CertSigningRequest.InitializeCertificateRequestUsingRSA(
            SubjectName, HashAlgorithm::SHA256, RSASignaturePadding::Pkcs1);

        CertSigningRequest.AddX509BasicConstraintToCertificateRequest(false, false, 0, true);

        CertSigningRequest.AddX509KeyUsageToCertificateRequest(16 + 128, false);

        CertSigningRequest.CreateSelfSigned(CreateDateTime(Today, 000000T), CreateDateTime(Today + 365, 000000T), X509ContentType::Cert, CertBase64Value);

        X509Certificate2.GetCertificateSubject(CertBase64Value, '', Subject);
        Assert.AreEqual(SubjectName, Subject, 'Self signed certificate generation failed.');
    end;

    local procedure GetSubjectName(): Text
    begin
        exit(StrSubstNo('CN=www.%1.com,C=US', Any.AlphabeticText(8)));
    end;
}